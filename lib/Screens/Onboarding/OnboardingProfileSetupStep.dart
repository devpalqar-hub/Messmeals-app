import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/Utils/AppColors.dart';
import 'package:mess/Screens/Utils/AppToast.dart';

/// Onboarding Step 1 — logo, cover image, tags and food type only. The rest
/// of the mess profile (name/phone/email/address/description) was already
/// collected at signup, so it isn't repeated here; the fuller edit screen
/// (MessProfileSettingsScreen, under Settings) covers all of that later.
class OnboardingProfileSetupStep extends StatefulWidget {
  const OnboardingProfileSetupStep({super.key});

  @override
  State<OnboardingProfileSetupStep> createState() =>
      OnboardingProfileSetupStepState();
}

class OnboardingProfileSetupStepState
    extends State<OnboardingProfileSetupStep> {
  static const List<String> tagOptions = [
    'HOME STYLE FOOD',
    'HYGIENIC KITCHEN',
    'AFFORDABLE PRICING',
    'ON TIME SERVING',
    'STUDENT FRIENDLY',
    'FAMILY MESS',
  ];

  static const Map<String, IconData> tagIcons = {
    'HOME STYLE FOOD': Icons.restaurant_outlined,
    'HYGIENIC KITCHEN': Icons.clean_hands_outlined,
    'AFFORDABLE PRICING': Icons.sell_outlined,
    'ON TIME SERVING': Icons.access_time_outlined,
    'STUDENT FRIENDLY': Icons.school_outlined,
    'FAMILY MESS': Icons.family_restroom_outlined,
  };

  final List<String> selectedTags = [];
  String? selectedFoodType; // 'VEG' or 'NON VEG'

  File? logoFile;
  File? coverFile;
  String? existingIconUrl;
  String? existingCoverUrl;

  bool isUploadingLogo = false;
  bool isUploadingCover = false;
  bool isSaving = false;

  late final HomeScreenController homeCtrl;

  @override
  void initState() {
    super.initState();
    homeCtrl = Get.find<HomeScreenController>();

    final mess = homeCtrl.messes.firstWhereOrNull(
      (m) => m.id == homeCtrl.selectedMessId,
    );
    if (mess != null) {
      existingIconUrl = mess.icon;
      if (mess.foodTypes.isNotEmpty) {
        selectedFoodType = mess.foodTypes.first;
      }
      selectedTags.addAll(
        mess.tags
            .map((t) => t.replaceAll('_', ' '))
            .where(tagOptions.contains),
      );
    }
  }

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => logoFile = File(picked.path));
  }

  Future<void> _pickCover() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => coverFile = File(picked.path));
  }

  /// Uploads any newly picked images and saves tags/food type/icon/cover to
  /// the mess. Returns true on success — called by the wizard's Continue
  /// button, which only advances if this returns true.
  Future<bool> save() async {
    final messId = homeCtrl.selectedMessId;
    if (messId == null || messId.isEmpty) {
      AppToast.error("Your mess is still loading — please wait a moment.");
      return false;
    }

    final mess = homeCtrl.messes.firstWhereOrNull((m) => m.id == messId);
    if (mess == null) {
      AppToast.error("Couldn't find your mess. Please try again.");
      return false;
    }

    setState(() => isSaving = true);

    try {
      String? iconUrl = existingIconUrl;
      if (logoFile != null) {
        setState(() => isUploadingLogo = true);
        final urls = await homeCtrl.uploadImages([logoFile!]);
        if (urls.isNotEmpty) iconUrl = urls.first;
        if (mounted) setState(() => isUploadingLogo = false);
      }

      String? coverUrl = existingCoverUrl;
      if (coverFile != null) {
        setState(() => isUploadingCover = true);
        final urls = await homeCtrl.uploadImages([coverFile!]);
        if (urls.isNotEmpty) coverUrl = urls.first;
        if (mounted) setState(() => isUploadingCover = false);
      }

      final ok = await homeCtrl.updateMess(
        messId: messId,
        name: mess.name ?? '',
        description: mess.description ?? '',
        address: mess.address ?? '',
        phone: mess.phone ?? '',
        email: mess.email ?? '',
        isActive: mess.isActive ?? true,
        isPremium: mess.isPremium ?? false,
        isVerified: mess.isVerified ?? false,
        openingHours: mess.openingHours,
        location: mess.location ?? '',
        districtId: mess.districtId,
        foodTypes:
            selectedFoodType == null
                ? []
                : [selectedFoodType!.trim().replaceAll(' ', '_')],
        tags: selectedTags.map((t) => t.trim().replaceAll(' ', '_')).toList(),
        features: mess.features,
        icon: iconUrl,
      );

      if (!ok) {
        AppToast.error("Couldn't save your mess profile. Please try again.");
        return false;
      }

      if (coverFile != null && coverUrl != null) {
        await homeCtrl.addCoverImage(messId: messId, imageUrl: coverUrl);
      }

      await homeCtrl.fetchMyMesses();
      return true;
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  String _tagLabel(String tag) {
    final words = tag.toLowerCase().split(' ');
    return words
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 4.h),
        Text(
          "Set up your mess profile",
          style: GoogleFonts.poppins(
            fontSize: 19.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          "Add a logo, cover image, tags and food type so customers recognize your mess.",
          style: GoogleFonts.poppins(
            fontSize: 12.5.sp,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 22.h),

        // Logo
        Text(
          "Mess Logo",
          style: GoogleFonts.poppins(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            GestureDetector(
              onTap: _pickLogo,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                      image:
                          logoFile != null
                              ? DecorationImage(
                                image: FileImage(logoFile!),
                                fit: BoxFit.cover,
                              )
                              : (existingIconUrl != null &&
                                      existingIconUrl!.isNotEmpty
                                  ? DecorationImage(
                                    image: NetworkImage(existingIconUrl!),
                                    fit: BoxFit.cover,
                                  )
                                  : null),
                    ),
                    child:
                        isUploadingLogo
                            ? Center(
                              child: SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                            : (logoFile == null &&
                                    (existingIconUrl == null ||
                                        existingIconUrl!.isEmpty)
                                ? Icon(
                                  Icons.storefront_outlined,
                                  color: Colors.grey.shade400,
                                  size: 26.sp,
                                )
                                : null),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 22.w,
                      height: 22.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(Icons.add, color: Colors.white, size: 13.sp),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                "Upload your mess logo\nJPG, PNG (max 2MB)",
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 20.h),

        // Cover image
        Text(
          "Cover Image",
          style: GoogleFonts.poppins(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _pickCover,
          child:
              isUploadingCover
                  ? Container(
                    height: 108.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )
                  : (coverFile != null ||
                      (existingCoverUrl != null &&
                          existingCoverUrl!.isNotEmpty))
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child:
                        coverFile != null
                            ? Image.file(
                              coverFile!,
                              height: 108.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                            : Image.network(
                              existingCoverUrl!,
                              height: 108.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                  )
                  : DottedUploadBox(
                    height: 108.h,
                    icon: Icons.add_photo_alternate_outlined,
                    label: "Add a cover image · JPG, PNG (max 5MB)",
                  ),
        ),

        SizedBox(height: 20.h),

        // Tags
        Text(
          "Mess Tags",
          style: GoogleFonts.poppins(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          "Select tags that describe your mess",
          style: GoogleFonts.poppins(
            fontSize: 11.5.sp,
            color: Colors.grey.shade400,
          ),
        ),
        SizedBox(height: 10.h),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
          childAspectRatio: 2.9,
          children: tagOptions.map((tag) => _tagTile(tag)).toList(),
        ),
        SizedBox(height: 20.h),

        // Food type
        Text(
          "Food Type",
          style: GoogleFonts.poppins(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          "Select the primary food type of your mess",
          style: GoogleFonts.poppins(
            fontSize: 11.5.sp,
            color: Colors.grey.shade400,
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(child: _foodTypeTile('VEG', 'Vegetarian')),
            SizedBox(width: 10.w),
            Expanded(child: _foodTypeTile('NON VEG', 'Non-Vegetarian')),
          ],
        ),

        SizedBox(height: 12.h),
      ],
    );
  }

  Widget _tagTile(String tag) {
    final isSelected = selectedTags.contains(tag);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedTags.remove(tag);
          } else {
            selectedTags.add(tag);
          }
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.shade300,
                width: isSelected ? 1.4 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Colors.white
                            : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    tagIcons[tag] ?? Icons.sell_outlined,
                    size: 15.sp,
                    color:
                        isSelected
                            ? AppColors.primaryDark
                            : Colors.grey.shade500,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _tagLabel(tag),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected
                              ? AppColors.primaryDark
                              : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                width: 18.w,
                height: 18.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(Icons.check, size: 11.sp, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _foodTypeTile(String value, String label) {
    final isSelected = selectedFoodType == value;
    return GestureDetector(
      onTap: () => setState(() => selectedFoodType = value),
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primary.withOpacity(0.10) : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.primaryDark : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

class DottedUploadBox extends StatelessWidget {
  final double height;
  final IconData icon;
  final String label;

  const DottedUploadBox({
    super.key,
    required this.height,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26.sp, color: Colors.grey.shade400),
          SizedBox(height: 6.h),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
