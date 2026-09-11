// DELIVERY PARTNER MODULE — DISABLED (admin-only build for now)
// Entire file commented out below; not wired into the app.
/*
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess/Screens/DeliveryPartner/Profile/Service/DeliveryProfileController.dart';
import 'package:mess/Screens/DeliveryPartner/Profile/Views/DocumentUploadScreen.dart';
import 'package:mess/Screens/DeliveryPartner/Profile/Views/EditDeliveryProfileScreen.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class DeliveryProfileScreen extends StatelessWidget {
  const DeliveryProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            title: const Text("Logout"),
            content: const Text("Are you sure you want to logout?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Logout", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await Get.put(AuthController()).logout(showMessage: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DeliveryProfileController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GetBuilder<DeliveryProfileController>(
          builder: (ctrl) {
            final profile = ctrl.profile;

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Profile",
                        style: GoogleFonts.poppins(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await Get.to(() => const EditDeliveryProfileScreen());
                          controller.fetchProfile();
                        },
                        child: Icon(Icons.edit_outlined, color: AppColors.primary, size: 20.sp),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),

                  if (ctrl.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    Center(
                      child: Column(
                        children: [
                          Container(
                            height: 72.w,
                            width: 72.w,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              profile != null && profile.name.isNotEmpty
                                  ? profile.name[0].toUpperCase()
                                  : '?',
                              style: GoogleFonts.poppins(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            profile?.name ?? '',
                            style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            profile?.phone ?? '',
                            style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey.shade600),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "Delivery Partner",
                            style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    Text(
                      "Account Status",
                      style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success, size: 18.sp),
                          SizedBox(width: 8.w),
                          Text(
                            (profile?.isActive ?? true)
                                ? "Your account is verified and active."
                                : "Your account is currently inactive.",
                            style: GoogleFonts.poppins(fontSize: 12.sp, color: const Color(0xFF111827)),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    Text(
                      "Vehicle Details",
                      style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.two_wheeler_outlined, color: AppColors.primary, size: 20.sp),
                          SizedBox(width: 10.w),
                          Text(
                            "${profile?.vehicleType ?? 'Two Wheeler'}"
                            "${(profile?.vehicleNumber.isNotEmpty ?? false) ? ' • ${profile!.vehicleNumber}' : ''}",
                            style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    Text(
                      "Documents",
                      style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8.h),
                    _documentRow("Driver's Licence", ctrl.licenseVerified),
                    SizedBox(height: 8.h),
                    _documentRow("Vehicle RC", ctrl.rcVerified),

                    SizedBox(height: 20.h),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Get.to(() => const DocumentUploadScreen()),
                        icon: Icon(Icons.upload_file_outlined, size: 16.sp, color: AppColors.primary),
                        label: Text(
                          "Manage Documents",
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () => _logout(context),
                        icon: Icon(Icons.logout, size: 16.sp, color: Colors.red.shade400),
                        label: Text(
                          "Logout",
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _documentRow(String label, bool verified) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.badge_outlined, size: 18.sp, color: AppColors.primary),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(label, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w500)),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: (verified ? AppColors.success : AppColors.warning).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              verified ? "Verified" : "Pending",
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: verified ? AppColors.success : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

*/
