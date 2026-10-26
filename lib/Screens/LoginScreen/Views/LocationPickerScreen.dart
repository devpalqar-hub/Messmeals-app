import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'package:mess/Screens/Utils/AppColors.dart';
import 'package:mess/Screens/Utils/AppToast.dart';
import 'package:mess/Screens/Utils/MapConfig.dart';

/// What [LocationPickerScreen] hands back — the picked point plus whatever
/// a reverse-geocode lookup found for it (postal code may be null if
/// Mapbox has no postcode data for that exact spot).
class PickedLocation {
  final LatLng latLng;
  final String? postalCode;
  final String? placeName;
  final String? fullAddress;

  PickedLocation({
    required this.latLng,
    this.postalCode,
    this.placeName,
    this.fullAddress,
  });
}

class _SearchResult {
  final String placeName;
  final LatLng center;

  _SearchResult({required this.placeName, required this.center});
}

/// Swiggy/Zomato-style location picker — a draggable map with a fixed
/// center pin, a search bar to jump to an address, a "Current location"
/// pill, and a bottom card that live-updates with the resolved place name
/// and address as the map settles, confirmed via "Confirm & proceed".
class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerScreen({super.key, this.initialLocation});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  // Geographic center of India — a neutral starting point (zoomed out, not
  // any specific city) used only until the device's real GPS location (or
  // a search/initial pick) replaces it.
  static const _fallback = LatLng(22.3511, 78.6677);
  static const _fallbackZoom = 4.5;
  static const _pinZoom = 17.0;

  final MapController _mapController = MapController();
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  late LatLng _center;
  bool _isLocating = false;
  bool _isConfirming = false;
  bool _isResolvingAddress = false;

  String? _placeName;
  String? _fullAddress;
  String? _postalCode;

  List<_SearchResult> _searchResults = [];
  Timer? _idleDebounce;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _center = widget.initialLocation!;
      _reverseGeocode(_center);
    } else {
      // Starts on the neutral fallback with no address lookup — GPS
      // resolving below replaces it almost immediately; only reverse-
      // geocode the fallback itself if GPS genuinely can't be used.
      _center = _fallback;
      _useCurrentLocation(silent: true, fallbackIfUnavailable: true);
    }
  }

  @override
  void dispose() {
    _idleDebounce?.cancel();
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Reverse geocoding — resolves the pinned point into a place name, a
  // full address line, and (if Mapbox has one) a postal code, all from a
  // single lookup.
  // ---------------------------------------------------------------------
  Future<void> _reverseGeocode(LatLng point) async {
    setState(() => _isResolvingAddress = true);
    try {
      final uri = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/'
        '${point.longitude},${point.latitude}.json'
        '?access_token=$mapboxAccessToken&types=address,poi,neighborhood,place',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return;

      final decoded = jsonDecode(response.body);
      final features = decoded is Map ? decoded['features'] : null;
      if (features is! List || features.isEmpty) return;

      final feature = features.first as Map<String, dynamic>;
      final placeName = feature['text']?.toString();
      final fullAddress = feature['place_name']?.toString();

      String? postcode;
      final context = feature['context'];
      if (context is List) {
        for (final c in context) {
          final id = (c is Map ? c['id'] : null)?.toString() ?? '';
          if (id.startsWith('postcode')) {
            postcode = c['text']?.toString();
            break;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _placeName =
            (placeName != null && placeName.isNotEmpty)
                ? placeName
                : 'Selected location';
        _fullAddress = fullAddress;
        _postalCode = postcode;
      });
    } catch (e) {
      debugPrint('REVERSE GEOCODE ERROR: $e');
    } finally {
      if (mounted) setState(() => _isResolvingAddress = false);
    }
  }

  void _onMapIdle(LatLng point) {
    _idleDebounce?.cancel();
    _idleDebounce = Timer(const Duration(milliseconds: 600), () {
      _reverseGeocode(point);
    });
  }

  // ---------------------------------------------------------------------
  // Forward search (autocomplete)
  // ---------------------------------------------------------------------
  Future<void> _searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    try {
      final uri = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/'
        '${Uri.encodeComponent(query)}.json'
        '?access_token=$mapboxAccessToken&autocomplete=true&limit=6'
        '&proximity=${_center.longitude},${_center.latitude}',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return;

      final decoded = jsonDecode(response.body);
      final features = decoded is Map ? decoded['features'] : null;
      if (features is! List) return;

      final results =
          features
              .whereType<Map>()
              .map((f) {
                final center = f['center'];
                if (center is! List || center.length < 2) return null;
                return _SearchResult(
                  placeName: f['place_name']?.toString() ?? '',
                  center: LatLng(
                    (center[1] as num).toDouble(),
                    (center[0] as num).toDouble(),
                  ),
                );
              })
              .whereType<_SearchResult>()
              .toList();

      if (!mounted) return;
      setState(() => _searchResults = results);
    } catch (e) {
      debugPrint('SEARCH PLACES ERROR: $e');
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 400),
      () => _searchPlaces(value),
    );
  }

  void _selectSearchResult(_SearchResult result) {
    _searchFocus.unfocus();
    _searchCtrl.clear();
    setState(() {
      _searchResults = [];
      _center = result.center;
    });
    _mapController.move(result.center, _pinZoom);
    _reverseGeocode(result.center);
  }

  // ---------------------------------------------------------------------
  // Current location
  // ---------------------------------------------------------------------
  /// [fallbackIfUnavailable] — when GPS can't be used for any reason
  /// (services off, permission denied, lookup failure), resolves the
  /// address of whatever [_center] already is (the neutral fallback point)
  /// instead of leaving the bottom card stuck on "Finding your location…".
  Future<void> _useCurrentLocation({
    bool silent = false,
    bool fallbackIfUnavailable = false,
  }) async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!silent) AppToast.error('Please turn on location services');
        if (fallbackIfUnavailable) _reverseGeocode(_center);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!silent) {
          AppToast.error('Location permission is needed to pin your mess');
        }
        if (fallbackIfUnavailable) _reverseGeocode(_center);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final here = LatLng(position.latitude, position.longitude);
      if (!mounted) return;
      setState(() => _center = here);
      _mapController.move(here, _pinZoom);
      _reverseGeocode(here);
    } catch (e) {
      if (!silent) AppToast.error('Could not get your current location');
      if (fallbackIfUnavailable) _reverseGeocode(_center);
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _confirmLocation() async {
    setState(() => _isConfirming = true);
    Get.back(
      result: PickedLocation(
        latLng: _center,
        postalCode: _postalCode,
        placeName: _placeName,
        fullAddress: _fullAddress,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm = !_isConfirming && !_isResolvingAddress;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: widget.initialLocation != null ? _pinZoom : _fallbackZoom,
              onPositionChanged: (position, hasGesture) {
                _center = position.center;
                if (hasGesture) _onMapIdle(position.center);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: mapboxTileUrlTemplate('streets-v12'),
                userAgentPackageName: 'com.messmeals.app',
              ),
            ],
          ),

          // Fixed center pin, drop-pin style with a soft ground shadow — the
          // picked point is always the map's center, so the pin never
          // moves; the map pans under it.
          IgnorePointer(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 46.sp,
                    color: AppColors.primaryDark,
                  ),
                  Container(
                    width: 10.w,
                    height: 4.h,
                    margin: EdgeInsets.only(top: 1.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  SizedBox(height: 44.h),
                ],
              ),
            ),
          ),

          // Top search bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _roundIconButton(
                          icon: Icons.arrow_back,
                          onTap: () => Get.back(),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Container(
                            height: 44.h,
                            padding: EdgeInsets.symmetric(horizontal: 14.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _searchCtrl,
                                    focusNode: _searchFocus,
                                    onChanged: _onSearchChanged,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.5.sp,
                                      color: const Color(0xFF111827),
                                    ),
                                    decoration: InputDecoration(
                                      isCollapsed: true,
                                      border: InputBorder.none,
                                      hintText: 'Search an area or address',
                                      hintStyle: GoogleFonts.poppins(
                                        fontSize: 13.sp,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.search,
                                  size: 20.sp,
                                  color: Colors.grey.shade500,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (_searchResults.isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(top: 8.h),
                        constraints: BoxConstraints(maxHeight: 260.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          itemCount: _searchResults.length,
                          separatorBuilder:
                              (_, __) => Divider(
                                height: 1,
                                color: Colors.grey.shade100,
                              ),
                          itemBuilder: (_, i) {
                            final r = _searchResults[i];
                            return InkWell(
                              onTap: () => _selectSearchResult(r),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 12.h,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 17.sp,
                                      color: Colors.grey.shade500,
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Text(
                                        r.placeName,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.5.sp,
                                          color: const Color(0xFF111827),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom: "Current location" pill + confirm card, stacked so the
          // pill always sits right above the card regardless of its height.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 16.w, bottom: 14.h),
                      child: Material(
                        color: Colors.white,
                        elevation: 3,
                        borderRadius: BorderRadius.circular(24.r),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24.r),
                          onTap: _isLocating ? null : () => _useCurrentLocation(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 10.h,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _isLocating
                                    ? SizedBox(
                                      width: 15.w,
                                      height: 15.w,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primaryDark,
                                      ),
                                    )
                                    : Icon(
                                      Icons.my_location,
                                      size: 16.sp,
                                      color: AppColors.primaryDark,
                                    ),
                                SizedBox(width: 7.w),
                                Text(
                                  'Current location',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 20.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 20.sp,
                              color: AppColors.primaryDark,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isResolvingAddress
                                        ? 'Finding your location…'
                                        : (_placeName ?? 'Selected location'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF111827),
                                    ),
                                  ),
                                  if (!_isResolvingAddress &&
                                      _fullAddress != null) ...[
                                    SizedBox(height: 3.h),
                                    Text(
                                      _fullAddress!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        SizedBox(
                          width: double.infinity,
                          height: 52.h,
                          child: ElevatedButton(
                            onPressed: canConfirm ? _confirmLocation : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: AppColors.primary
                                  .withOpacity(0.6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            child:
                                _isConfirming
                                    ? SizedBox(
                                      width: 22.w,
                                      height: 22.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : Text(
                                      'Confirm & proceed',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundIconButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Icon(icon, size: 18.sp, color: const Color(0xFF111827)),
        ),
      ),
    );
  }
}
