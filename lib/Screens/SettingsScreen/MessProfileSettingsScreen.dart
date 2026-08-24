import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:mess/Screens/HomeScreen/Model/MessModel.dart';
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/LoginScreen/Model/DistrictModel.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/Utils/AppColors.dart';
import 'package:mess/Screens/Utils/AppToast.dart';
import 'package:mess/main.dart';

class MessProfileSettingsScreen extends StatefulWidget {
  /// When true, this screen always opens in "Create Mess" mode, even if the
  /// user already has a mess selected elsewhere in the app (used by the
  /// "Add New Mess" option in the home screen's mess dropdown).
  final bool forceCreate;

  const MessProfileSettingsScreen({super.key, this.forceCreate = false});

  @override
  State<MessProfileSettingsScreen> createState() =>
      _MessProfileSettingsScreenState();
}

class _MessProfileSettingsScreenState
    extends State<MessProfileSettingsScreen> {
  late final HomeScreenController homeCtrl;

  // ---------------------------------------------------------------------------
  // Controllers
  // ---------------------------------------------------------------------------

  late final TextEditingController messNameCtrl;
  late final TextEditingController phoneCtrl;
  late final TextEditingController emailCtrl;
  late final TextEditingController cityCtrl;
  late final TextEditingController stateCtrl;
  late final TextEditingController addressCtrl;
  late final TextEditingController descriptionCtrl;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  bool isSaving = false;

  // True while the full mess details (GET /mess/{id}) are being fetched to
  // prefill this screen when editing an existing mess.
  bool isLoadingMessDetails = false;

  // District id from the loaded mess, applied once districtList is ready
  // (loading order between fetchDistricts() and the mess detail fetch isn't
  // guaranteed).
  String? _pendingDistrictId;

  // True while an image picked from camera/gallery is being uploaded.
  bool isUploadingCover = false;
  bool isUploadingGallery = false;

  bool isActive = true;
  bool isVerified = true;
  bool isPremium = false;

  // Existing image URLs
  String? existingCoverImage;
  final List<String> existingGalleryImages = [];

  // Newly added image URLs
  final List<String> galleryImageUrls = [];

  // ---------------------------------------------------------------------------
  // Districts
  // ---------------------------------------------------------------------------

  List<DistrictModel> districtList = [];
  DistrictModel? selectedDistrict;
  bool districtsLoading = false;

  // ---------------------------------------------------------------------------
  // Food Types
  // ---------------------------------------------------------------------------

  static const List<String> foodTypes = [
    'VEG',
    'NON VEG',
    'MIXED',
  ];

  String? selectedFoodType;

  // ---------------------------------------------------------------------------
  // Tags
  // ---------------------------------------------------------------------------

  static const List<String> tagOptions = [
    'HOME STYLE FOOD',
    'MONTHLY PLANS',
    'DAILY FRESH MEALS',
    'FIXED MENU',
    'HYGIENIC KITCHEN',
    'AFFORDABLE PRICING',
    'VEG AND NON VEG',
    'ON TIME SERVING',
    'QUALITY INGREDIENTS',
    'CONSISTENT TASTE',
    'STUDENT FRIENDLY',
    'FAMILY MESS',
    'FLEXIBLE BOOKING',
    'NO HIDDEN CHARGES',
    'TRUSTED MESS',
  ];

  final List<String> selectedTags = [];

  // ---------------------------------------------------------------------------
  // Features
  // ---------------------------------------------------------------------------

  static const List<String> featureOptions = [
    'wifi',
    'parking',
    'home-delivery',
  ];

  final List<String> selectedFeatures = [];

  // ---------------------------------------------------------------------------
  // Opening hours
  // ---------------------------------------------------------------------------

  static const List<String> weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final List<Map<String, dynamic>> openingHours = [];

  // ---------------------------------------------------------------------------
  // Init
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    homeCtrl = Get.find<HomeScreenController>();

    // Cached mess from the messes list — used to paint the form instantly
    // while the full details (see _loadFullMessDetails) load in the
    // background.
    final mess =
        widget.forceCreate
            ? null
            : homeCtrl.messes.firstWhereOrNull(
              (item) => item.id == homeCtrl.selectedMessId,
            );

    messNameCtrl = TextEditingController(text: mess?.name ?? '');
    phoneCtrl = TextEditingController(text: mess?.phone ?? '');
    emailCtrl = TextEditingController(text: mess?.email ?? '');
    cityCtrl = TextEditingController(text: mess?.location ?? '');
    stateCtrl = TextEditingController();
    addressCtrl = TextEditingController(text: mess?.address ?? '');
    descriptionCtrl = TextEditingController(text: mess?.description ?? '');

    if (mess != null) {
      _applyMessDetails(mess, refreshControllers: false);
    }

    _initializeDefaultOpeningHours();

    fetchDistricts();

    // The cached mess above only has whatever the messes-list endpoint
    // returns — fetch the full mess record so every field (tags, features,
    // opening hours, district, images, ...) is prefilled correctly.
    final editingMessId = widget.forceCreate ? null : homeCtrl.selectedMessId;
    if (editingMessId != null && editingMessId.isNotEmpty) {
      _loadFullMessDetails(editingMessId);
    }
  }

  // ===========================================================================
  // LOAD EXISTING MESS (edit mode)
  // ===========================================================================

  Future<void> _loadFullMessDetails(String messId) async {
    setState(() => isLoadingMessDetails = true);

    final mess = await homeCtrl.fetchMessDetails(messId);

    if (!mounted) return;

    if (mess != null) {
      _applyMessDetails(mess, refreshControllers: true);
    }

    setState(() => isLoadingMessDetails = false);
  }

  /// Applies a loaded [MessModel] onto all the form fields. When
  /// [refreshControllers] is false (called from initState before the
  /// TextEditingControllers exist yet) only the non-controller state is set.
  void _applyMessDetails(MessModel mess, {required bool refreshControllers}) {
    if (refreshControllers) {
      messNameCtrl.text = mess.name ?? messNameCtrl.text;
      phoneCtrl.text = mess.phone ?? phoneCtrl.text;
      emailCtrl.text = mess.email ?? emailCtrl.text;
      addressCtrl.text = mess.address ?? addressCtrl.text;
      descriptionCtrl.text = mess.description ?? descriptionCtrl.text;
      // The API only stores a single free-text `location` string (no
      // separate city/state) — best effort: show it in the City field.
      cityCtrl.text = mess.location ?? cityCtrl.text;
    }

    isActive = mess.isActive ?? isActive;
    isPremium = mess.isPremium ?? isPremium;
    isVerified = mess.isVerified ?? isVerified;

    selectedFoodType = _foodTypeFromApi(mess.foodTypes) ?? selectedFoodType;

    if (mess.tags.isNotEmpty) {
      selectedTags
        ..clear()
        ..addAll(
          mess.tags
              .map((tag) => tag.replaceAll('_', ' '))
              .where(tagOptions.contains),
        );
    }

    if (mess.features.isNotEmpty) {
      selectedFeatures
        ..clear()
        ..addAll(mess.features.where(featureOptions.contains));
    }

    if (mess.openingHours.isNotEmpty) {
      final parsed = _openingHoursFromApi(mess.openingHours);
      if (parsed.isNotEmpty) {
        openingHours
          ..clear()
          ..addAll(parsed);
      }
    }

    _applyImages(mess.images);

    _pendingDistrictId = mess.districtId;
    _applyPendingDistrictIfReady();

    // Only trigger a rebuild when called after the initial build (i.e. from
    // the async detail fetch) — calling setState() from initState() is
    // unnecessary since the first build hasn't happened yet.
    if (refreshControllers && mounted) setState(() {});
  }

  /// Maps [{"VEG"}, {"NON_VEG"}, {"VEG","NON_VEG"}] back to the UI's single
  /// VEG / NON VEG / MIXED dropdown value — reverse of _buildFoodTypes().
  String? _foodTypeFromApi(List<String> types) {
    if (types.isEmpty) return null;

    final normalized = types.map((e) => e.toUpperCase()).toSet();

    final hasVeg = normalized.contains('VEG');
    final hasNonVeg = normalized.contains('NON_VEG');

    if (hasVeg && hasNonVeg) return 'MIXED';
    if (hasNonVeg) return 'NON VEG';
    if (hasVeg) return 'VEG';

    return null;
  }

  /// Parses "9:30-16:0" style ranges back into TimeOfDay — reverse of
  /// _timeForApi() / _buildOpeningHours().
  TimeOfDay? _parseTimeToken(String token) {
    final parts = token.trim().split(':');
    if (parts.isEmpty) return null;

    final hour = int.tryParse(parts[0]);
    if (hour == null) return null;

    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

  List<Map<String, dynamic>> _openingHoursFromApi(Map<String, String> raw) {
    final result = <Map<String, dynamic>>[];

    for (final entry in raw.entries) {
      final parts = entry.value.split('-');
      if (parts.length != 2) continue;

      final from = _parseTimeToken(parts[0]);
      final to = _parseTimeToken(parts[1]);
      if (from == null || to == null) continue;

      result.add({'day': entry.key, 'from': from, 'to': to});
    }

    return result;
  }

  /// Splits the flat `images` list from the API into a cover image and
  /// gallery images. The API doesn't clearly document how a cover image is
  /// distinguished from gallery ones, so this uses an image's "type" field
  /// when present and otherwise falls back to treating the first image as
  /// the cover.
  void _applyImages(List<MessImageModel> images) {
    if (images.isEmpty) return;

    existingCoverImage = null;
    existingGalleryImages.clear();

    for (final img in images) {
      if (img.url.isEmpty) continue;

      if (img.isCover && existingCoverImage == null) {
        existingCoverImage = img.url;
      } else {
        existingGalleryImages.add(img.url);
      }
    }

    if (existingCoverImage == null && existingGalleryImages.isNotEmpty) {
      existingCoverImage = existingGalleryImages.removeAt(0);
    }
  }

  void _applyPendingDistrictIfReady() {
    final pendingId = _pendingDistrictId;
    if (pendingId == null || pendingId.isEmpty) return;

    final match = districtList.firstWhereOrNull((d) => d.id == pendingId);
    if (match != null) {
      selectedDistrict = match;
      _pendingDistrictId = null;
    }
  }

  void _initializeDefaultOpeningHours() {
    openingHours.add({
      'day': 'Monday',
      'from': const TimeOfDay(hour: 9, minute: 30),
      'to': const TimeOfDay(hour: 16, minute: 0),
    });
  }

  @override
  void dispose() {
    messNameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    addressCtrl.dispose();
    descriptionCtrl.dispose();

    super.dispose();
  }

  // ===========================================================================
  // AUTH
  // ===========================================================================

  Map<String, String> get _headers {
    String token = bearerToken.trim();

    if (token.isEmpty) {
      return {
        'Accept': '*/*',
        'Content-Type': 'application/json',
      };
    }

    if (!token.toLowerCase().startsWith('bearer ')) {
      token = 'Bearer $token';
    }

    return {
      'Accept': '*/*',
      'Content-Type': 'application/json',
      'Authorization': token,
    };
  }

  // ===========================================================================
  // DISTRICTS
  // ===========================================================================

  Future<void> fetchDistricts() async {
    if (districtsLoading) return;

    setState(() {
      districtsLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/districts?page=1&limit=100'),
        headers: _headers,
      );

      debugPrint('District response: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List list = decoded is Map
            ? (decoded['data'] ?? [])
            : decoded;

        districtList = list
            .map(
              (e) => DistrictModel.fromJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .toList();
      } else {
        debugPrint(
          'Failed to fetch districts: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('District fetch error: $e');
    } finally {
      _applyPendingDistrictIfReady();

      if (mounted) {
        setState(() {
          districtsLoading = false;
        });
      }
    }
  }

  void _showDistrictBottomSheet() {
    Get.bottomSheet(
      Container(
        height: 500.h,
        padding: EdgeInsets.only(
          top: 16.h,
          left: 16.w,
          right: 16.w,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24.r),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Select District',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: districtList.isEmpty
                  ? Center(
                      child: Text(
                        'No districts found',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: districtList.length,
                      separatorBuilder: (_, __) => Divider(
                        color: Colors.grey.shade100,
                        height: 1,
                      ),
                      itemBuilder: (_, index) {
                        final district = districtList[index];

                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          title: Text(
                            district.name,
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                          ),
                          onTap: () {
                            setState(() {
                              selectedDistrict = district;
                            });

                            Get.back();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ===========================================================================
  // OPENING HOURS
  // ===========================================================================

  void _addHours() {
    final usedDays = openingHours
        .map((e) => e['day'] as String)
        .toSet();

    final availableDay = weekDays.firstWhereOrNull(
      (day) => !usedDays.contains(day),
    );

    if (availableDay == null) {
      AppToast.show(
        title: 'Opening Hours',
        message: 'All days have already been added.',
      );
      return;
    }

    setState(() {
      openingHours.add({
        'day': availableDay,
        'from': const TimeOfDay(
          hour: 9,
          minute: 30,
        ),
        'to': const TimeOfDay(
          hour: 16,
          minute: 0,
        ),
      });
    });
  }

  Future<void> _pickTime(
    int index,
    bool isFrom,
  ) async {
    final current =
        openingHours[index][isFrom ? 'from' : 'to'] as TimeOfDay;

    final picked = await showTimePicker(
      context: context,
      initialTime: current,
      builder: (ctx, child) {
        return MediaQuery(
          data: MediaQuery.of(ctx).copyWith(
            alwaysUse24HourFormat: false,
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      openingHours[index][isFrom ? 'from' : 'to'] = picked;
    });
  }

  String _timeForApi(TimeOfDay time) {
    if (time.minute == 0) {
      return '${time.hour}';
    }

    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  Map<String, String> _buildOpeningHours() {
    return {
      for (final item in openingHours)
        item['day'] as String:
            '${_timeForApi(item['from'] as TimeOfDay)}-'
            '${_timeForApi(item['to'] as TimeOfDay)}',
    };
  }

  // ===========================================================================
  // FOOD TYPES
  // ===========================================================================

  List<String> _buildFoodTypes() {
    switch (selectedFoodType) {
      case 'VEG':
        return ['VEG'];

      case 'NON VEG':
        return ['NON_VEG'];

      case 'MIXED':
        return [
          'VEG',
          'NON_VEG',
        ];

      default:
        return [];
    }
  }

  // ===========================================================================
  // IMAGE PICKING (camera / photo library) + UPLOAD
  // ===========================================================================

  /// Shows a bottom sheet letting the user choose Camera or Photo Library.
  Future<ImageSource?> _showImageSourceSheet() {
    return Get.bottomSheet<ImageSource>(
      Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.camera_alt_outlined,
                color: AppColors.primary,
              ),
              title: Text(
                'Camera',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library_outlined,
                color: AppColors.primary,
              ),
              title: Text(
                'Photo Library',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _addCoverImageUrl() async {
    final source = await _showImageSourceSheet();
    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => isUploadingCover = true);

    // Upload the picked file so we get back a hosted URL — the mess APIs
    // (createMess/updateMess/addCoverImage) only accept image URLs, not files.
    final urls = await homeCtrl.uploadImages([File(picked.path)]);

    if (mounted) {
      setState(() {
        if (urls.isNotEmpty) existingCoverImage = urls.first;
        isUploadingCover = false;
      });
    }
  }

  Future<void> _addGalleryImageUrl() async {
    final source = await _showImageSourceSheet();
    if (source == null) return;

    List<File> files;

    if (source == ImageSource.camera) {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      files = picked == null ? [] : [File(picked.path)];
    } else {
      final picked = await ImagePicker().pickMultiImage(imageQuality: 85);
      files = picked.map((x) => File(x.path)).toList();
    }

    if (files.isEmpty) return;

    setState(() => isUploadingGallery = true);

    // Upload the picked files so we get back hosted URLs — the mess gallery
    // API only accepts image URLs, not files.
    final urls = await homeCtrl.uploadImages(files);

    if (mounted) {
      setState(() {
        galleryImageUrls.addAll(urls);
        isUploadingGallery = false;
      });
    }
  }

  // ===========================================================================
  // TAGS / FEATURES
  // ===========================================================================

  Future<void> _openMultiSelectSheet({
    required String title,
    required List<String> options,
    required List<String> selected,
  }) async {
    final tempSelected = List<String>.from(selected);

    await Get.bottomSheet(
      StatefulBuilder(
        builder: (context, sheetSetState) {
          return Container(
            height: 560.h,
            padding: EdgeInsets.only(
              top: 16.h,
              left: 16.w,
              right: 16.w,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24.r),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                Expanded(
                  child: ListView.builder(
                    itemCount: options.length,
                    itemBuilder: (_, index) {
                      final option = options[index];

                      final checked =
                          tempSelected.contains(option);

                      return CheckboxListTile(
                        value: checked,
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity:
                            ListTileControlAffinity.leading,
                        title: Text(
                          option,
                          style: GoogleFonts.poppins(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onChanged: (value) {
                          sheetSetState(() {
                            if (value == true) {
                              if (!tempSelected.contains(option)) {
                                tempSelected.add(option);
                              }
                            } else {
                              tempSelected.remove(option);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        selected
                          ..clear()
                          ..addAll(tempSelected);
                      });

                      Get.back();
                    },
                    child: Text(
                      'Done',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  // ===========================================================================
  // SAVE
  // ===========================================================================

  Future<void> _saveChanges() async {
    if (messNameCtrl.text.trim().isEmpty) {
      _showError(
        'Please enter the mess name.',
      );
      return;
    }

    if (phoneCtrl.text.trim().isEmpty) {
      _showError(
        'Please enter the phone number.',
      );
      return;
    }

    if (emailCtrl.text.trim().isEmpty) {
      _showError(
        'Please enter the email address.',
      );
      return;
    }

    if (selectedDistrict == null) {
      _showError(
        'Please select a district.',
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final messId = widget.forceCreate ? null : homeCtrl.selectedMessId;

      final isEditing = messId != null && messId.trim().isNotEmpty;

      final location = [
        cityCtrl.text.trim(),
        stateCtrl.text.trim(),
      ].where((e) => e.isNotEmpty).join(', ');

      final tags =
          selectedTags
              .map((tag) => tag.trim().replaceAll(' ', '_'))
              .toList();

      // -----------------------------------------------------------------------
      // Create / update the mess using the shared API calls already defined
      // on HomeScreenController, instead of duplicating raw http requests
      // here.
      // -----------------------------------------------------------------------

      String? savedMessId;

      if (isEditing) {
        final ok = await homeCtrl.updateMess(
          messId: messId,
          name: messNameCtrl.text.trim(),
          description: descriptionCtrl.text.trim(),
          address: addressCtrl.text.trim(),
          phone: phoneCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          isActive: isActive,
          isPremium: isPremium,
          isVerified: isVerified,
          openingHours: _buildOpeningHours(),
          location: location,
          districtId: selectedDistrict!.id,
          foodTypes: _buildFoodTypes(),
          tags: tags,
          features: selectedFeatures,
        );

        if (!ok) {
          throw Exception('Mess update failed.');
        }

        savedMessId = messId;
      } else {
        final newMess = await homeCtrl.createMess(
          name: messNameCtrl.text.trim(),
          description: descriptionCtrl.text.trim(),
          address: addressCtrl.text.trim(),
          phone: phoneCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          isActive: isActive,
          isPremium: isPremium,
          isVerified: isVerified,
          openingHours: _buildOpeningHours(),
          location: location,
          districtId: selectedDistrict!.id,
          foodTypes: _buildFoodTypes(),
          messAdminIds: [
            if (homeCtrl.user?.id.isNotEmpty ?? false) homeCtrl.user!.id,
          ],
          tags: tags,
          features: selectedFeatures,
        );

        if (newMess == null || newMess.id == null) {
          throw Exception('Mess creation failed.');
        }

        savedMessId = newMess.id;
      }

      if (savedMessId == null || savedMessId.isEmpty) {
        throw Exception(
          'Mess ID was not returned by the API.',
        );
      }

      // -----------------------------------------------------------------------
      // Cover / gallery images — already uploaded to hosted URLs when picked
      // from camera/photo library (see _addCoverImageUrl / _addGalleryImageUrl).
      // -----------------------------------------------------------------------

      if (existingCoverImage != null &&
          existingCoverImage!.trim().isNotEmpty) {
        await homeCtrl.addCoverImage(
          messId: savedMessId,
          imageUrl: existingCoverImage!.trim(),
        );
      }

      if (galleryImageUrls.isNotEmpty) {
        await homeCtrl.addGalleryImages(
          messId: savedMessId,
          imageUrls: galleryImageUrls,
        );
      }

      // -----------------------------------------------------------------------
      // Update local selected mess
      // -----------------------------------------------------------------------

      homeCtrl.selectedMessId = savedMessId;

      // Refresh home data / mess list.
      await homeCtrl.fetchMyMesses();

      if (!mounted) return;

      // Use AppToast (native toast) instead of Get.snackbar here — Get.snackbar
      // relies on GetX's own overlay, which can momentarily be out of sync
      // right after the bottom sheets used for image picking above, and
      // throws "No Overlay widget found" if fired right before Get.back().
      AppToast.success(
        isEditing
            ? 'Mess profile updated successfully.'
            : 'Mess created successfully.',
      );

      Get.back();
    } catch (e) {
      debugPrint(
        'Save mess profile error: $e',
      );

      if (!mounted) return;

      _showError(
        'Could not save the mess profile. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  void _showError(String message) {
    AppToast.error(message);
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final isEditing =
        !widget.forceCreate &&
        homeCtrl.selectedMessId != null &&
        homeCtrl.selectedMessId!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _appBar(
                isEditing: isEditing,
              ),
              _header(),
              _basicInformationCard(),
              _statusCard(),
              _openingHoursCard(),
              _foodTypeCard(),
              _tagsCard(),
              _featuresCard(),
              _coverImageCard(),
              _galleryCard(),
              _saveButton(
                isEditing: isEditing,
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // APP BAR
  // ===========================================================================

  Widget _appBar({
    required bool isEditing,
  }) {
    return Container(
      height: 56.h,
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: 4.w,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
            ),
            color: AppColors.textPrimary,
          ),
          Expanded(
            child: Text(
              isEditing
                  ? ' Mess Profile'
                  : 'Create Mess',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (isLoadingMessDetails)
            SizedBox(
              width: 18.w,
              height: 18.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          else
            SizedBox(width: 18.w),
          SizedBox(width: 13.w),
        ],
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _header() {
    return Container(
      margin: EdgeInsets.fromLTRB(
        20.w,
        18.h,
        20.w,
        0,
      ),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Container(
            width: 58.w,
            height: 58.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.18,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  messNameCtrl.text.isNotEmpty
                      ? messNameCtrl.text
                      : 'Your Mess',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  !widget.forceCreate && homeCtrl.selectedMessId != null
                      ? 'Manage your mess profile'
                      : 'Create your mess profile',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(
                      alpha: 0.82,
                    ),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // CARD
  // ===========================================================================

  Widget _cardWrap({
    required String title,
    Widget? trailing,
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        20.w,
        16.h,
        20.w,
        0,
      ),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(
              alpha: 0.05,
            ),
            blurRadius: 14,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          SizedBox(height: 14.h),
          ...children,
        ],
      ),
    );
  }

  // ===========================================================================
  // FIELD
  // ===========================================================================

  Widget _labeledField({
    required String label,
    bool required = false,
    required IconData icon,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType =
        TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 14.h,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(
                  0xFF374151,
                ),
              ),
              children: required
                  ? [
                      TextSpan(
                        text: ' *',
                        style: GoogleFonts.poppins(
                          color: AppColors.error,
                        ),
                      ),
                    ]
                  : [],
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            decoration: BoxDecoration(
              color: const Color(
                0xFFFAFAFA,
              ),
              borderRadius:
                  BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical:
                      maxLines > 1 ? 14.h : 15.h,
                ),
                prefixIcon: maxLines > 1
                    ? null
                    : Icon(
                        icon,
                        size: 18.sp,
                        color:
                            AppColors.primary,
                      ),
                hintText: hint,
                hintStyle:
                    GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: const Color(
                    0xFF9CA3AF,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BASIC INFORMATION
  // ===========================================================================

  Widget _basicInformationCard() {
    return _cardWrap(
      title: 'Basic Information',
      children: [
        _labeledField(
          label: 'Mess Name',
          required: true,
          icon: Icons.storefront_outlined,
          controller: messNameCtrl,
          hint: 'Enter mess name',
        ),

        _labeledField(
          label: 'Phone',
          required: true,
          icon: Icons.call_outlined,
          controller: phoneCtrl,
          hint: '9876543210',
          keyboardType:
              TextInputType.phone,
        ),

        _labeledField(
          label: 'Email',
          required: true,
          icon: Icons.mail_outline,
          controller: emailCtrl,
          hint: 'mess@email.com',
          keyboardType:
              TextInputType.emailAddress,
        ),

        _locationFields(),

        _labeledField(
          label: 'Address',
          icon: Icons.map_outlined,
          controller: addressCtrl,
          hint: 'Full address',
          maxLines: 2,
        ),

        _districtField(),

        _labeledField(
          label: 'Description',
          icon: Icons.notes_outlined,
          controller: descriptionCtrl,
          hint: 'Describe the mess...',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _locationFields() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 14.h,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Location',
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: const Color(
                0xFF374151,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                child: _smallField(
                  controller: cityCtrl,
                  hint: 'City',
                  icon:
                      Icons.location_on_outlined,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _smallField(
                  controller: stateCtrl,
                  hint: 'State',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(
          0xFFFAFAFA,
        ),
        borderRadius:
            BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding:
              EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 15.h,
          ),
          prefixIcon: icon == null
              ? null
              : Icon(
                  icon,
                  size: 18.sp,
                  color: AppColors.primary,
                ),
          hintText: hint,
          hintStyle:
              GoogleFonts.poppins(
            fontSize: 14.sp,
            color: const Color(
              0xFF9CA3AF,
            ),
          ),
        ),
      ),
    );
  }

  Widget _districtField() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 14.h,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: 'District',
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(
                  0xFF374151,
                ),
              ),
              children: [
                TextSpan(
                  text: ' *',
                  style: GoogleFonts.poppins(
                    color:
                        AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 6.h),
          InkWell(
            onTap: districtsLoading
                ? null
                : _showDistrictBottomSheet,
            borderRadius:
                BorderRadius.circular(12.r),
            child: Container(
              padding:
                  EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 14.h,
              ),
              decoration:
                  BoxDecoration(
                color: const Color(
                  0xFFFAFAFA,
                ),
                borderRadius:
                    BorderRadius.circular(
                  12.r,
                ),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 18.sp,
                    color:
                        AppColors.primary,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      selectedDistrict
                              ?.name ??
                          (districtsLoading
                              ? 'Loading districts...'
                              : 'Select District'),
                      style:
                          GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: selectedDistrict ==
                                null
                            ? const Color(
                                0xFF9CA3AF,
                              )
                            : AppColors
                                .textPrimary,
                      ),
                    ),
                  ),
                  if (districtsLoading)
                    SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child:
                          const CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  else
                    const Icon(
                      Icons
                          .keyboard_arrow_down_rounded,
                      color:
                          Color(0xFF6B7280),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // STATUS
  // ===========================================================================

  Widget _statusCard() {
    return _cardWrap(
      title: 'Status',
      children: [
        _toggleRow(
          'Active',
          'Mess is visible to customers',
          isActive,
          (value) {
            setState(() {
              isActive = value;
            });
          },
          AppColors.primary,
        ),
        SizedBox(height: 16.h),
        _toggleRow(
          'Verified',
          'Verified by Messmeals team',
          isVerified,
          (value) {
            setState(() {
              isVerified = value;
            });
          },
          AppColors.success,
        ),
        SizedBox(height: 16.h),
        _toggleRow(
          'Premium',
          'Featured listing placement',
          isPremium,
          (value) {
            setState(() {
              isPremium = value;
            });
          },
          AppColors.warning,
        ),
      ],
    );
  }

  Widget _toggleRow(
    String label,
    String sub,
    bool value,
    ValueChanged<bool> onChanged,
    Color activeColor,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight:
                      FontWeight.w500,
                  color:
                      AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                sub,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color:
                      AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: activeColor,
        ),
      ],
    );
  }

  // ===========================================================================
  // OPENING HOURS
  // ===========================================================================

  Widget _openingHoursCard() {
    return _cardWrap(
      title: 'Opening Hours',
      trailing: _addChip(
        icon: Icons.add,
        label: 'Add Hours',
        onTap: _addHours,
      ),
      children: [
        ...List.generate(
          openingHours.length,
          (index) {
            final item = openingHours[index];

            final from =
                item['from'] as TimeOfDay;

            final to =
                item['to'] as TimeOfDay;

            return Container(
              margin: EdgeInsets.only(
                bottom: 10.h,
              ),
              padding:
                  EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFFAFAFA,
                ),
                borderRadius:
                    BorderRadius.circular(
                  12.r,
                ),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item['day'] as String,
                      style:
                          GoogleFonts.poppins(
                        fontSize: 13.5.sp,
                        fontWeight:
                            FontWeight.w600,
                        color:
                            AppColors.textPrimary,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () =>
                        _pickTime(
                      index,
                      true,
                    ),
                    child: Text(
                      from.format(context),
                      style:
                          GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color:
                            AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(
                      horizontal: 7.w,
                    ),
                    child: Text(
                      'to',
                      style:
                          GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color:
                            const Color(
                          0xFF9CA3AF,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () =>
                        _pickTime(
                      index,
                      false,
                    ),
                    child: Text(
                      to.format(context),
                      style:
                          GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color:
                            AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _addChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(10.r),
      child: Container(
        padding:
            EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 7.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary
              .withValues(alpha: 0.10),
          borderRadius:
              BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13.sp,
              color:
                  AppColors.primary,
            ),
            SizedBox(width: 5.w),
            Text(
              label,
              style:
                  GoogleFonts.poppins(
                fontSize: 12.5.sp,
                fontWeight:
                    FontWeight.w600,
                color:
                    AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // FOOD TYPE
  // ===========================================================================

  Widget _foodTypeCard() {
    return _cardWrap(
      title: 'Food Type',
      children: [
        Container(
          padding:
              EdgeInsets.symmetric(
            horizontal: 14.w,
          ),
          decoration: BoxDecoration(
            color: const Color(
              0xFFFAFAFA,
            ),
            borderRadius:
                BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child:
              DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedFoodType,
              isExpanded: true,
              hint: Row(
                children: [
                  Icon(
                    Icons
                        .restaurant_menu_outlined,
                    size: 18.sp,
                    color:
                        AppColors.primary,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Select Food Type',
                    style:
                        GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color:
                          const Color(
                        0xFF9CA3AF,
                      ),
                    ),
                  ),
                ],
              ),
              items: foodTypes
                  .map(
                    (type) =>
                        DropdownMenuItem(
                      value: type,
                      child: Text(
                        type,
                        style:
                            GoogleFonts.poppins(
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedFoodType =
                      value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // TAGS
  // ===========================================================================

  Widget _tagsCard() {
    return _chipPickerCard(
      title: 'Tags',
      icon: Icons.sell_outlined,
      selected: selectedTags,
      onTap: () => _openMultiSelectSheet(
        title: 'Select Tags',
        options: tagOptions,
        selected: selectedTags,
      ),
    );
  }

  // ===========================================================================
  // FEATURES
  // ===========================================================================

  Widget _featuresCard() {
    return _chipPickerCard(
      title: 'Features',
      icon: Icons.star_border_outlined,
      selected: selectedFeatures,
      onTap: () => _openMultiSelectSheet(
        title: 'Select Features',
        options: featureOptions,
        selected: selectedFeatures,
      ),
    );
  }

  Widget _chipPickerCard({
    required String title,
    required IconData icon,
    required List<String> selected,
    required VoidCallback onTap,
  }) {
    return _cardWrap(
      title: title,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(12.r),
          child: Container(
            width: double.infinity,
            padding:
                EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 13.h,
            ),
            decoration: BoxDecoration(
              color: const Color(
                0xFFFAFAFA,
              ),
              borderRadius:
                  BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: selected.isEmpty
                ? Row(
                    children: [
                      Icon(
                        icon,
                        size: 18.sp,
                        color:
                            AppColors.primary,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Text(
                        'Select $title',
                        style:
                            GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color:
                              const Color(
                            0xFF9CA3AF,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons
                            .keyboard_arrow_down_rounded,
                        color:
                            Color(0xFF6B7280),
                      ),
                    ],
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selected
                        .map(
                          (item) =>
                              Container(
                            padding:
                                EdgeInsets
                                    .symmetric(
                              horizontal:
                                  10.w,
                              vertical: 6.h,
                            ),
                            decoration:
                                BoxDecoration(
                              color: AppColors
                                  .primary
                                  .withValues(
                                alpha: 0.10,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                8.r,
                              ),
                            ),
                            child: Text(
                              item,
                              style: GoogleFonts
                                  .poppins(
                                fontSize:
                                    11.5.sp,
                                fontWeight:
                                    FontWeight
                                        .w600,
                                color:
                                    AppColors
                                        .primary,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // COVER IMAGE
  // ===========================================================================

  Widget _coverImageCard() {
    return _cardWrap(
      title: 'Cover Image',
      trailing: _addChip(
        icon: Icons.add,
        label: 'Add Image',
        onTap: isUploadingCover ? () {} : _addCoverImageUrl,
      ),
      children: [
        if (isUploadingCover)
          _uploadingBox()
        else if (existingCoverImage != null &&
            existingCoverImage!.isNotEmpty)
          ClipRRect(
            borderRadius:
                BorderRadius.circular(14.r),
            child: Image.network(
              existingCoverImage!,
              height: 150.h,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) {
                return _imageErrorBox();
              },
            ),
          )
        else
          _emptyImageBox(
            title: 'No cover image',
            icon:
                Icons.image_outlined,
            onTap: _addCoverImageUrl,
          ),
      ],
    );
  }

  Widget _uploadingBox() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 30.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 22.w,
            height: 22.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Uploading...',
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // GALLERY
  // ===========================================================================

  Widget _galleryCard() {
    final allImages = [
      ...existingGalleryImages,
      ...galleryImageUrls,
    ];

    return _cardWrap(
      title: 'Gallery Images',
      trailing: _addChip(
        icon: Icons.add_photo_alternate_outlined,
        label: 'Add Image',
        onTap: isUploadingGallery ? () {} : _addGalleryImageUrl,
      ),
      children: [
        if (isUploadingGallery)
          _uploadingBox()
        else if (allImages.isEmpty)
          _emptyImageBox(
            title: 'No gallery images',
            icon:
                Icons.photo_library_outlined,
            onTap: _addGalleryImageUrl,
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            itemCount: allImages.length,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
            ),
            itemBuilder: (_, index) {
              final url = allImages[index];

              return ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  12.r,
                ),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) {
                    return _imageErrorBox();
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _emptyImageBox({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(14.r),
      child: Container(
        width: double.infinity,
        padding:
            EdgeInsets.symmetric(
          vertical: 30.h,
        ),
        decoration: BoxDecoration(
          color: const Color(
            0xFFFAFAFA,
          ),
          borderRadius:
              BorderRadius.circular(14.r),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30.sp,
              color:
                  AppColors.primary,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style:
                  GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight:
                    FontWeight.w500,
                color:
                    AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageErrorBox() {
    return Container(
      color: const Color(
        0xFFF3F4F6,
      ),
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: Colors.grey,
        ),
      ),
    );
  }

  // ===========================================================================
  // SAVE BUTTON
  // ===========================================================================

  Widget _saveButton({
    required bool isEditing,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20.w,
        22.h,
        20.w,
        4.h,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52.h,
        child: ElevatedButton(
          onPressed:
              isSaving ? null : _saveChanges,
          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                AppColors.primary,
            elevation: 4,
            shadowColor:
                AppColors.primary
                    .withValues(alpha: 0.35),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                14.r,
              ),
            ),
          ),
          child: isSaving
              ? SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child:
                      const CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Text(
                  isEditing
                      ? 'Save Changes'
                      : 'Create Mess',
                  style:
                      GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight:
                        FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}