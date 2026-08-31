import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mess/Screens/HomeScreen/Model/MessModel.dart';
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/Utils/AppColors.dart';
import 'package:mess/Screens/Utils/AppToast.dart';

/// Edit screen for the mess owner's existing mess profile.
///
/// This screen is edit-only — a mess is created through the separate
/// "Add New Mess" flow (see AddMessBottomSheet), so this screen always
/// operates on `HomeScreenController.selectedMessId`.
class MessProfileSettingsScreen extends StatefulWidget {
  const MessProfileSettingsScreen({super.key});

  @override
  State<MessProfileSettingsScreen> createState() =>
      _MessProfileSettingsScreenState();
}

class _MessProfileSettingsScreenState extends State<MessProfileSettingsScreen> {
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
  // prefill this screen.
  bool isLoadingMessDetails = false;

  // District isn't editable from this screen, but the loaded value is kept
  // and re-sent unchanged on save for the same reason as isVerified/isPremium
  // above.
  String? _districtId;

  // True while an image picked from camera/gallery is being uploaded.
  bool isUploadingCover = false;
  bool isUploadingGallery = false;
  bool isUploadingIcon = false;

  // Active isn't editable from this screen — shown as a read-only badge in
  // the header, and always re-sent unchanged on save so this form can never
  // accidentally clear it.
  bool isActive = true;

  // Verified / Premium are set by the Messmeals team, not the mess admin —
  // shown as read-only badges only, and always re-sent unchanged on save so
  // this form can never accidentally clear either flag.
  bool isVerified = false;
  bool isPremium = false;

  // Opening hours aren't editable from this screen, but the loaded value is
  // kept and re-sent unchanged on save for the same reason as above.
  Map<String, String> _openingHours = {};

  // Existing image URLs
  String? existingCoverImage;
  // Already-saved gallery images (keeps each image's id so it can be removed via
  // DELETE /mess/:messId/gallery/images/:imageId).
  final List<MessImageModel> existingGalleryImages = [];
  // ids of existing gallery images currently being removed (shows a spinner on
  // that thumbnail while the delete request is in flight).
  final Set<String> removingGalleryImageIds = {};

  // Optional mess icon/logo — a single hosted image URL, separate from the
  // cover/gallery photos.
  String? existingIcon;

  // Newly added image URLs
  final List<String> galleryImageUrls = [];

  // ---------------------------------------------------------------------------
  // Food Types
  // ---------------------------------------------------------------------------

  static const List<String> foodTypeOptions = ['VEG', 'NON VEG'];

  final List<String> selectedFoodTypes = [];

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

  // Features aren't editable from this screen, but the loaded value is kept
  // and re-sent unchanged on save for the same reason as isVerified/isPremium
  // above.
  List<String> _features = [];

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
    final mess = homeCtrl.messes.firstWhereOrNull(
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

    // The cached mess above only has whatever the messes-list endpoint
    // returns — fetch the full mess record so every field (tags, features,
    // images, ...) is prefilled correctly.
    final editingMessId = homeCtrl.selectedMessId;
    if (editingMessId != null && editingMessId.isNotEmpty) {
      _loadFullMessDetails(editingMessId);
    }
  }

  // ===========================================================================
  // LOAD EXISTING MESS
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

    if (mess.foodTypes.isNotEmpty) {
      selectedFoodTypes
        ..clear()
        ..addAll(
          mess.foodTypes
              .map((type) => type.replaceAll('_', ' '))
              .where(foodTypeOptions.contains),
        );
    }

    if (mess.tags.isNotEmpty) {
      selectedTags
        ..clear()
        ..addAll(
          mess.tags
              .map((tag) => tag.replaceAll('_', ' '))
              .where(tagOptions.contains),
        );
    }

    _features = List<String>.from(mess.features);

    _openingHours = Map<String, String>.from(mess.openingHours);

    _applyImages(mess.images);

    existingIcon = mess.icon;

    _districtId = mess.districtId;

    // Only trigger a rebuild when called after the initial build (i.e. from
    // the async detail fetch) — calling setState() from initState() is
    // unnecessary since the first build hasn't happened yet.
    if (refreshControllers && mounted) setState(() {});
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
        existingGalleryImages.add(img);
      }
    }

    if (existingCoverImage == null && existingGalleryImages.isNotEmpty) {
      existingCoverImage = existingGalleryImages.removeAt(0).url;
    }
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
  // FOOD TYPES
  // ===========================================================================

  List<String> _buildFoodTypes() {
    return selectedFoodTypes
        .map((type) => type.trim().replaceAll(' ', '_'))
        .toList();
  }

  // ===========================================================================
  // IMAGE PICKING (photo library only) + UPLOAD
  // ===========================================================================

  Future<void> _addCoverImageUrl() async {
    // Gallery only — no camera capture.
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => isUploadingCover = true);

    // Upload the picked file so we get back a hosted URL — the mess APIs
    // (updateMess/addCoverImage) only accept image URLs, not files.
    final urls = await homeCtrl.uploadImages([File(picked.path)]);

    if (mounted) {
      setState(() {
        if (urls.isNotEmpty) existingCoverImage = urls.first;
        isUploadingCover = false;
      });
    }
  }

  Future<void> _pickIconImage() async {
    // Gallery only — no camera capture.
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => isUploadingIcon = true);

    // Upload the picked file so we get back a hosted URL — updateMess only
    // accepts an icon URL, not a file.
    final urls = await homeCtrl.uploadImages([File(picked.path)]);

    if (mounted) {
      setState(() {
        if (urls.isNotEmpty) existingIcon = urls.first;
        isUploadingIcon = false;
      });
    }
  }

  void _removeIconImage() {
    setState(() => existingIcon = null);
  }

  Future<void> _addGalleryImageUrl() async {
    // Gallery photos only — no camera capture here, unlike the cover image.
    final picked = await ImagePicker().pickMultiImage(imageQuality: 85);
    final files = picked.map((x) => File(x.path)).toList();

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
  // TAGS / FOOD TYPE — shared multi-select sheet
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
            padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (tempSelected.isNotEmpty)
                      TextButton(
                        onPressed: () => sheetSetState(tempSelected.clear),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Clear',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
                Divider(height: 22.h, color: AppColors.border),
                Expanded(
                  child: ListView.separated(
                    itemCount: options.length,
                    separatorBuilder:
                        (_, __) => Divider(
                          height: 1,
                          color: AppColors.border.withValues(alpha: 0.6),
                        ),
                    itemBuilder: (_, index) {
                      final option = options[index];

                      final checked = tempSelected.contains(option);

                      return CheckboxListTile(
                        value: checked,
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        title: Text(
                          option,
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
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
                SizedBox(height: 8.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
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
                      tempSelected.isEmpty
                          ? 'Done'
                          : 'Apply (${tempSelected.length})',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
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
    final messId = homeCtrl.selectedMessId;

    if (messId == null || messId.trim().isEmpty) {
      _showError('No mess selected to update.');
      return;
    }

    if (messNameCtrl.text.trim().isEmpty) {
      _showError('Please enter the mess name.');
      return;
    }

    if (phoneCtrl.text.trim().isEmpty) {
      _showError('Please enter the phone number.');
      return;
    }

    if (emailCtrl.text.trim().isEmpty) {
      _showError('Please enter the email address.');
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final location = [
        cityCtrl.text.trim(),
        stateCtrl.text.trim(),
      ].where((e) => e.isNotEmpty).join(', ');

      final tags =
          selectedTags.map((tag) => tag.trim().replaceAll(' ', '_')).toList();

      final ok = await homeCtrl.updateMess(
        messId: messId,
        name: messNameCtrl.text.trim(),
        description: descriptionCtrl.text.trim(),
        address: addressCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        // Not editable here — re-sent as loaded so saving never clears them.
        isActive: isActive,
        isPremium: isPremium,
        isVerified: isVerified,
        openingHours: _openingHours,
        location: location,
        // Not editable here — re-sent as loaded so saving never clears it.
        districtId: _districtId,
        foodTypes: _buildFoodTypes(),
        tags: tags,
        // Not editable here — re-sent as loaded so saving never clears them.
        features: _features,
        icon: existingIcon,
      );

      if (!ok) {
        throw Exception('Mess update failed.');
      }

      // -----------------------------------------------------------------------
      // Cover / gallery images — already uploaded to hosted URLs when picked
      // from camera/photo library (see _addCoverImageUrl / _addGalleryImageUrl).
      // -----------------------------------------------------------------------

      if (existingCoverImage != null && existingCoverImage!.trim().isNotEmpty) {
        await homeCtrl.addCoverImage(
          messId: messId,
          imageUrl: existingCoverImage!.trim(),
        );
      }

      if (galleryImageUrls.isNotEmpty) {
        await homeCtrl.addGalleryImages(
          messId: messId,
          imageUrls: galleryImageUrls,
        );
      }

      // Refresh home data / mess list.
      await homeCtrl.fetchMyMesses();

      if (!mounted) return;

      // Use AppToast (native toast) instead of Get.snackbar here — Get.snackbar
      // relies on GetX's own overlay, which can momentarily be out of sync
      // right after the bottom sheets used for image picking above, and
      // throws "No Overlay widget found" if fired right before Get.back().
      AppToast.success('Mess profile updated successfully.');

      Get.back();
    } catch (e) {
      debugPrint('Save mess profile error: $e');

      if (!mounted) return;

      _showError('Could not save the mess profile. Please try again.');
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
    final hasMess =
        homeCtrl.selectedMessId != null && homeCtrl.selectedMessId!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child:
            hasMess
                ? Stack(
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 90.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _appBar(),
                          _header(),
                          _basicInformationCard(),
                          _foodTypeCard(),
                          _tagsCard(),
                          _iconCard(),
                          _coverImageCard(),
                          _galleryCard(),
                          SizedBox(height: 8.h),
                        ],
                      ),
                    ),
                    Positioned(left: 0, right: 0, bottom: 0, child: _saveBar()),
                  ],
                )
                : Column(children: [_appBar(), Expanded(child: _emptyState())]),
      ),
    );
  }

  // ===========================================================================
  // APP BAR
  // ===========================================================================

  Widget _appBar() {
    return Container(
      height: 52.h,
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 17),
            color: AppColors.textPrimary,
            splashRadius: 20,
          ),
          Expanded(
            child: Text(
              'Mess Profile',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15.5.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: 40.w,
            child:
                isLoadingMessDetails
                    ? Center(
                      child: SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                    : null,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // EMPTY STATE (no mess to edit)
  // ===========================================================================

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68.w,
              height: 68.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.storefront_outlined,
                color: AppColors.primary,
                size: 30.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'No mess to show',
              style: GoogleFonts.poppins(
                fontSize: 15.5.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Add a mess from the mess switcher on the home screen, then come back here to manage its profile.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.5.sp,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _header() {
    final badges = <Widget>[
      if (isVerified) _headerBadge(Icons.verified, 'Verified'),
      if (isPremium) _headerBadge(Icons.workspace_premium, 'Premium'),
    ];

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.30),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  messNameCtrl.text.isNotEmpty
                      ? messNameCtrl.text
                      : 'Your Mess',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6.h),
                if (badges.isNotEmpty)
                  Wrap(spacing: 6.w, runSpacing: 6.h, children: badges)
                else
                  Text(
                    'Manage your mess profile',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 11.5.sp,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: (isActive ? Colors.white : Colors.black).withValues(
                alpha: isActive ? 0.20 : 0.18,
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color:
                        isActive ? Colors.greenAccent.shade100 : Colors.white70,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 5.w),
                Text(
                  isActive ? 'Active' : 'Inactive',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerBadge(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: Colors.white),
          SizedBox(width: 4.w),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
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
    IconData? icon,
    String? subtitle,
    Widget? trailing,
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, size: 14.sp, color: AppColors.primary),
                ),
                SizedBox(width: 9.w),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 1.h),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 10.5.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          SizedBox(height: 12.h),
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
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
              children:
                  required
                      ? [
                        TextSpan(
                          text: ' *',
                          style: GoogleFonts.poppins(color: AppColors.error),
                        ),
                      ]
                      : [],
            ),
          ),
          SizedBox(height: 5.h),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              style: GoogleFonts.poppins(
                fontSize: 13.5.sp,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 13.w,
                  vertical: maxLines > 1 ? 13.h : 13.5.h,
                ),
                prefixIcon:
                    maxLines > 1
                        ? null
                        : Icon(icon, size: 17.sp, color: AppColors.primary),
                prefixIconConstraints: BoxConstraints(
                  minWidth: 40.w,
                  minHeight: 0,
                ),
                hintText: hint,
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: const Color(0xFF9CA3AF),
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
      icon: Icons.storefront_outlined,
      children: [
        _labeledField(
          label: 'Mess Name',
          required: true,
          icon: Icons.storefront_outlined,
          controller: messNameCtrl,
          hint: 'Enter mess name',
        ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _labeledField(
                label: 'Phone',
                required: true,
                icon: Icons.call_outlined,
                controller: phoneCtrl,
                hint: '9876543210',
                keyboardType: TextInputType.phone,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _labeledField(
                label: 'Email',
                required: true,
                icon: Icons.mail_outline,
                controller: emailCtrl,
                hint: 'mess@email.com',
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ],
        ),

        _locationFields(),

        _labeledField(
          label: 'Address',
          icon: Icons.map_outlined,
          controller: addressCtrl,
          hint: 'Full address',
          maxLines: 2,
        ),

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
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location',
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
          SizedBox(height: 5.h),
          Row(
            children: [
              Expanded(
                child: _smallField(
                  controller: cityCtrl,
                  hint: 'City',
                  icon: Icons.location_on_outlined,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _smallField(controller: stateCtrl, hint: 'State'),
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
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(fontSize: 13.5.sp),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 13.5.h,
          ),
          prefixIcon:
              icon == null
                  ? null
                  : Icon(icon, size: 17.sp, color: AppColors.primary),
          prefixIconConstraints: BoxConstraints(minWidth: 36.w, minHeight: 0),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 13.sp,
            color: const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // FOOD TYPE
  // ===========================================================================

  Widget _foodTypeCard() {
    return _chipPickerCard(
      title: 'Food Type',
      icon: Icons.restaurant_menu_outlined,
      selected: selectedFoodTypes,
      onTap:
          () => _openMultiSelectSheet(
            title: 'Select Food Type',
            options: foodTypeOptions,
            selected: selectedFoodTypes,
          ),
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
      onTap:
          () => _openMultiSelectSheet(
            title: 'Select Tags',
            options: tagOptions,
            selected: selectedTags,
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
      icon: icon,
      subtitle: selected.isEmpty ? null : '${selected.length} selected',
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.border),
            ),
            child:
                selected.isEmpty
                    ? Row(
                      children: [
                        Icon(icon, size: 17.sp, color: AppColors.primary),
                        SizedBox(width: 9.w),
                        Text(
                          'Select $title',
                          style: GoogleFonts.poppins(
                            fontSize: 13.5.sp,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: const Color(0xFF6B7280),
                          size: 20.sp,
                        ),
                      ],
                    )
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children:
                                selected
                                    .map(
                                      (item) => Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 9.w,
                                          vertical: 5.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.10,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            7.r,
                                          ),
                                        ),
                                        child: Text(
                                          item,
                                          style: GoogleFonts.poppins(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: const Color(0xFF6B7280),
                          size: 20.sp,
                        ),
                      ],
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
    final hasCover =
        existingCoverImage != null && existingCoverImage!.isNotEmpty;

    return _cardWrap(
      title: 'Cover Image',
      icon: Icons.image_outlined,
      subtitle: 'Shown at the top of your mess listing',
      children: [
        if (isUploadingCover)
          _uploadingBox()
        else if (hasCover)
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Stack(
              children: [
                Image.network(
                  existingCoverImage!,
                  height: 140.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imageErrorBox(height: 140.h),
                ),
                Positioned(
                  right: 8.w,
                  bottom: 8.h,
                  child: _imageActionButton(
                    icon: Icons.edit_outlined,
                    label: 'Change',
                    onTap: _addCoverImageUrl,
                  ),
                ),
              ],
            ),
          )
        else
          _emptyImageBox(
            title: 'No cover image',
            subtitle: 'Tap to upload from camera or gallery',
            icon: Icons.add_photo_alternate_outlined,
            onTap: _addCoverImageUrl,
          ),
      ],
    );
  }

  // ===========================================================================
  // ICON / LOGO (optional)
  // ===========================================================================

  Widget _iconCard() {
    final hasIcon = existingIcon != null && existingIcon!.isNotEmpty;

    return _cardWrap(
      title: 'Icon',
      icon: Icons.emoji_food_beverage_outlined,
      subtitle: 'Optional — a small logo shown alongside your mess name',
      trailing:
          hasIcon
              ? _addChip(
                icon: Icons.close,
                label: 'Remove',
                onTap: _removeIconImage,
              )
              : null,
      children: [
        Row(
          children: [
            if (isUploadingIcon)
              SizedBox(
                width: 56.w,
                height: 56.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: AppColors.primary,
                ),
              )
            else
              InkWell(
                onTap: _pickIconImage,
                borderRadius: BorderRadius.circular(28.r),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28.r),
                  child:
                      hasIcon
                          ? Image.network(
                            existingIcon!,
                            width: 56.w,
                            height: 56.w,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => _imageErrorBox(height: 56.w),
                          )
                          : Container(
                            width: 56.w,
                            height: 56.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(28.r),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 20.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                ),
              ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                hasIcon
                    ? 'Tap the icon to change it'
                    : 'Tap to upload a square icon/logo',
                style: GoogleFonts.poppins(
                  fontSize: 11.5.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _imageActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12.sp, color: Colors.white),
            SizedBox(width: 4.w),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _uploadingBox() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 26.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 20.w,
            height: 20.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Uploading...',
            style: GoogleFonts.poppins(
              fontSize: 12.5.sp,
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

  /// Removes an already-saved gallery image — this one is live on the mess
  /// record, so it's deleted from the server immediately rather than waiting
  /// for the "Save" button.
  Future<void> _removeExistingGalleryImage(MessImageModel image) async {
    final messId = homeCtrl.selectedMessId;
    final imageId = image.id;
    if (messId == null || imageId == null) return;

    setState(() => removingGalleryImageIds.add(imageId));

    final ok = await homeCtrl.deleteGalleryImage(
      messId: messId,
      imageId: imageId,
    );

    if (!mounted) return;

    setState(() {
      removingGalleryImageIds.remove(imageId);
      if (ok) {
        existingGalleryImages.removeWhere((img) => img.id == imageId);
      }
    });
  }

  /// Removes a newly-picked image that hasn't been saved to the mess gallery
  /// yet — a plain local removal, nothing to call the server for.
  void _removeNewGalleryImage(String url) {
    setState(() => galleryImageUrls.remove(url));
  }

  Widget _galleryThumbnail({
    required String url,
    required VoidCallback onRemove,
    bool isRemoving = false,
  }) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imageErrorBox(),
            ),
          ),
        ),
        if (isRemoving)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        else
          Positioned(
            top: 4.h,
            right: 4.w,
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 12.sp, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _galleryCard() {
    final totalCount = existingGalleryImages.length + galleryImageUrls.length;

    return _cardWrap(
      title: 'Gallery Images',
      icon: Icons.photo_library_outlined,
      subtitle:
          totalCount == 0
              ? null
              : '$totalCount photo${totalCount == 1 ? '' : 's'}',
      trailing: _addChip(
        icon: Icons.add,
        label: 'Add',
        onTap: isUploadingGallery ? () {} : _addGalleryImageUrl,
      ),
      children: [
        if (isUploadingGallery)
          _uploadingBox()
        else if (totalCount == 0)
          _emptyImageBox(
            title: 'No gallery images',
            subtitle: 'Add a few photos of your food and kitchen',
            icon: Icons.photo_library_outlined,
            onTap: _addGalleryImageUrl,
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCount,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
            ),
            itemBuilder: (_, index) {
              if (index < existingGalleryImages.length) {
                final image = existingGalleryImages[index];
                return _galleryThumbnail(
                  url: image.url,
                  isRemoving: removingGalleryImageIds.contains(image.id),
                  onRemove: () => _removeExistingGalleryImage(image),
                );
              }

              final url =
                  galleryImageUrls[index - existingGalleryImages.length];
              return _galleryThumbnail(
                url: url,
                onRemove: () => _removeNewGalleryImage(url),
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
    String? subtitle,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: DottedBorderBox(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 24.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.border,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 22.sp, color: AppColors.primary),
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageErrorBox({double? height}) {
    return Container(
      height: height,
      color: const Color(0xFFF3F4F6),
      child: const Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 20),
      ),
    );
  }

  Widget _addChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12.sp, color: AppColors.primary),
            SizedBox(width: 4.w),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SAVE BAR (sticky footer)
  // ===========================================================================

  Widget _saveBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            onPressed: isSaving ? null : _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child:
                isSaving
                    ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 18.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Save Changes',
                          style: GoogleFonts.poppins(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}

/// Lightweight wrapper kept as a no-op passthrough so the empty-image
/// placeholders read clearly as "upload target" boxes without pulling in an
/// extra dependency for a dashed border. Swap this for a real dashed-border
/// package (e.g. `dotted_border`) if you want a true dashed outline.
class DottedBorderBox extends StatelessWidget {
  final Widget child;

  const DottedBorderBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) => child;
}
