import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess/Screens/LoginScreen/LoginScreen.dart';
import 'package:mess/Screens/Utils/Colors.dart';
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileBottomSheet extends StatelessWidget {
  ProfileBottomSheet({super.key});

  // Fetching the controller to access user details
  // Ensure the controller is already initialized before opening this sheet
  final HomeScreenController ctrl = Get.find<HomeScreenController>();

  void _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: onConfirm,
            child: Text(
              confirmText,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Extract user details with fallbacks
    final String name = ctrl.user?.name ?? "Unknown User";
    final String email = ctrl.user?.email ?? "";
    final String phone = ctrl.user?.phone ?? "";
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : "U";

    return SafeArea(
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "My Profile",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                InkWell(
                  onTap: () => Get.back(),
                  child: Icon(
                    Icons.close,
                    color: Colors.grey[600],
                    size: 20.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Profile Info Card
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26.r,
                    backgroundColor: PrimaryColor.withOpacity(0.15),
                    child: Text(
                      initial,
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: PrimaryColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        if (phone.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Text(
                            phone,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                        if (email.isNotEmpty)
                          Text(
                            email,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[700],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),
            Divider(color: Colors.grey.shade200, height: 1),
            SizedBox(height: 8.h),

            // Logout Option
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.black87,
                  size: 20.sp,
                ),
              ),
              title: Text(
                "Logout",
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              onTap: () {
                Get.back(); // Close bottom sheet
                _showConfirmationDialog(
                  title: "Logout",
                  message: "Are you sure you want to log out of your account?",
                  confirmText: "Logout",
                  confirmColor: PrimaryColor,
                  onConfirm: () async {
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
                    pref.clear();
                    Get.offAll(
                      LoginScreen(),
                      transition: Transition.rightToLeft,
                    );
                  },
                );
              },
            ),

            // Delete Account Option
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 20.sp,
                ),
              ),
              title: Text(
                "Delete Account",
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
              onTap: () {
                Get.back(); // Close bottom sheet
                _showConfirmationDialog(
                  title: "Delete Account",
                  message:
                      "This action is permanent and cannot be undone. All your data will be lost in 30 days. Are you sure?",
                  confirmText: "Delete",
                  confirmColor: Colors.red,
                  onConfirm: () async {
                    // TODO: Implement Delete Account Logic
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
                    pref.clear();
                    Get.offAll(
                      LoginScreen(),
                      transition: Transition.rightToLeft,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
