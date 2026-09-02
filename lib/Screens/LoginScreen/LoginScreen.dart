import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess/Screens/LoginScreen/OtScreen.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/LoginScreen/SignUpScreen.dart';
import 'package:mess/Screens/Utils/AppColors.dart';
import 'package:mess/Screens/Utils/AppToast.dart';

/// Simple, minimal sign-in screen: a plain white background, a small brand
/// mark, and a single phone-number field — no imagery, gradients, or
/// decorative chrome.
class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final AuthController authCtrl = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GetBuilder<AuthController>(
          builder: (_) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 56.h),

                  /// BRAND WORDMARK
                  Text(
                    "Messmeals",
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "ADMIN PORTAL",
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      color: Colors.grey.shade500,
                    ),
                  ),

                  SizedBox(height: 48.h),

                  /// WELCOME TEXT
                  Text(
                    "Welcome back",
                    style: GoogleFonts.poppins(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "Sign in with your phone number to continue",
                    style: GoogleFonts.poppins(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  SizedBox(height: 32.h),

                  Text(
                    "Phone Number",
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF374151),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  /// PHONE INPUT FIELD
                  _buildPhoneInputField(),

                  SizedBox(height: 24.h),

                  /// SEND OTP BUTTON
                  _buildSendOtpButton(context),

                  SizedBox(height: 28.h),

                  /// DIVIDER
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade200)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        child: Text(
                          "or",
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade500,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade200)),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  /// SIGN UP REDIRECT
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.poppins(
                            fontSize: 13.5.sp,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.to(() => SignUpScreen()),
                          child: Text(
                            "Sign Up",
                            style: GoogleFonts.poppins(
                              color: AppColors.primaryDark,
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Extracted Phone Input Field Widget
  Widget _buildPhoneInputField() {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          /// COUNTRY PICKER
          Container(
            width: 92.w,
            alignment: Alignment.center,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: authCtrl.selectedCountry,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey.shade500,
                  size: 20.sp,
                ),
                isDense: true,
                items:
                    ["IN", "US", "AE"]
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 20.w,
                                  height: 14.h,
                                  child: CountryPickerUtils.getDefaultFlagImage(
                                    CountryPickerUtils.getCountryByIsoCode(
                                      item,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  "+${CountryPickerUtils.getCountryByIsoCode(item).phoneCode}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    authCtrl.selectedCountry = value;
                    authCtrl.update();
                  }
                },
              ),
            ),
          ),

          /// VERTICAL DIVIDER
          Container(height: 22.h, width: 1, color: Colors.grey.shade200),

          /// TEXT FIELD
          Expanded(
            child: TextField(
              controller: authCtrl.phoneController,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: const Color(0xFF111827),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
                hintText: "Enter phone number",
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13.5.sp,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Extracted Button Widget
  Widget _buildSendOtpButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        onPressed:
            authCtrl.isLoading
                ? null
                : () async {
                  String phone = authCtrl.phoneController.text.trim();

                  if (phone.isEmpty) {
                    AppToast.show(
                      title: "Required",
                      message: "Please enter your phone number",
                    );
                    return;
                  }

                  bool success = await authCtrl.sendOtp(phone, silent: true);
                  if (success) {
                    Get.to(() => OtpVerificationScreen(phoneNumber: phone));
                  } else if (authCtrl.lastLoginUserNotFound) {
                    _showUserNotFoundSheet(context, phone);
                  } else {
                    AppToast.show(
                      title: "Error",
                      message:
                          authCtrl.lastErrorMessage.isNotEmpty
                              ? authCtrl.lastErrorMessage
                              : "Something went wrong. Please try again.",
                    );
                  }
                },
        child:
            authCtrl.isLoading
                ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                : Text(
                  "Send OTP",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }

  /// Shown when the entered phone number has no account associated
  /// with it. Lets the user re-check the number or head to Sign Up.
  void _showUserNotFoundSheet(BuildContext context, String phone) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24.w, 14.h, 24.w, 24.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// DRAG HANDLE
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  SizedBox(height: 22.h),

                  /// ICON
                  Container(
                    height: 64.h,
                    width: 64.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFDECEC),
                    ),
                    child: Icon(
                      Icons.person_search_rounded,
                      color: const Color(0xFFE05353),
                      size: 32.sp,
                    ),
                  ),
                  SizedBox(height: 18.h),

                  /// TITLE
                  Text(
                    "Account Not Found",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  /// MESSAGE
                  Text(
                    "We couldn't find an account for",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  /// PHONE NUMBER CHIP
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      "${authCtrl.countryCode} $phone",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  Text(
                    "Please check your number is correct, or create a new account to get started.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade500,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 26.h),

                  /// SIGN UP BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                        Get.to(() => SignUpScreen());
                      },
                      child: Text(
                        "Create New Account",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  /// CHECK NUMBER AGAIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: Text(
                        "Check Number Again",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF374151),
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
