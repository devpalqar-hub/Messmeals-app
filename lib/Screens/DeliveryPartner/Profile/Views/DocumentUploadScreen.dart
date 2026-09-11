// DELIVERY PARTNER MODULE — DISABLED (admin-only build for now)
// Entire file commented out below; not wired into the app.
/*
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mess/Screens/DeliveryPartner/Profile/Service/DeliveryProfileController.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class DocumentUploadScreen extends StatelessWidget {
  const DocumentUploadScreen({super.key});

  Future<void> _pick(BuildContext context, Future<void> Function(File) onPicked) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    await onPicked(File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DeliveryProfileController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        title: Text(
          "Documents",
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
      ),
      body: SafeArea(
        child: GetBuilder<DeliveryProfileController>(
          builder: (ctrl) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _documentCard(
                    context,
                    title: "Driver's Licence",
                    imageUrl: ctrl.licenseUrl,
                    verified: ctrl.licenseVerified,
                    isUploading: ctrl.isUploadingLicense,
                    onChange: () => _pick(context, controller.uploadLicense),
                  ),
                  SizedBox(height: 14.h),
                  _documentCard(
                    context,
                    title: "Vehicle RC",
                    imageUrl: ctrl.vehicleRcUrl,
                    verified: ctrl.rcVerified,
                    isUploading: ctrl.isUploadingRc,
                    onChange: () => _pick(context, controller.uploadVehicleRc),
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 16.sp, color: AppColors.primary),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            "Your documents will be verified by admin. You will be notified once the status changes.",
                            style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _documentCard(
    BuildContext context, {
    required String title,
    required String? imageUrl,
    required bool verified,
    required bool isUploading,
    required VoidCallback onChange,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 56.w,
            width: 56.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
              image:
                  imageUrl != null
                      ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                      : null,
            ),
            alignment: Alignment.center,
            child:
                imageUrl == null
                    ? Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 22.sp)
                    : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: (verified ? AppColors.success : AppColors.warning).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        verified ? "Verified" : "Pending",
                        style: GoogleFonts.poppins(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                          color: verified ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 32.h,
            child: OutlinedButton(
              onPressed: isUploading ? null : onChange,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red.shade300),
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              child:
                  isUploading
                      ? SizedBox(
                        height: 14.h,
                        width: 14.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Text(
                        "Change",
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade400,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

*/
