import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/LoginScreen/OtScreen.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/LoginScreen/SignUpScreen.dart';
import 'package:mess/Screens/Utils/AppToast.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final AuthController authCtrl = Get.put(AuthController());
  final Color primaryGreen = const Color(0xFF5BA43A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: GetBuilder<AuthController>(
        builder: (_) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        /// TOP HEADER SECTION (IMAGE + GRADIENT)
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/Firefly.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            /// Gradient overlay for text readability
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.6),
                                  Colors.black.withOpacity(0.2),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                            child: SafeArea(
                              bottom: false,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                  vertical: 40.h,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// LOGO + BRAND NAME
                                    Row(
                                      children: [
                                        Container(
                                          height: 54.h,
                                          width: 54.w,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                          ),
                                          child: Icon(
                                            Icons.restaurant,
                                            size: 28.sp,
                                            color: primaryGreen,
                                          ),
                                        ),
                                        SizedBox(width: 14.w),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: "Super",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24.sp,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      letterSpacing: -0.5,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: "Meals",
                                                    style: TextStyle(
                                                      color: primaryGreen,
                                                      fontSize: 24.sp,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      letterSpacing: -0.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              "ADMIN",
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.9,
                                                ),
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 50.h),

                                    /// WELCOME TEXT
                                    Text(
                                      "Welcome Back",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28.sp,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Text(
                                      "Sign in to continue to your account",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 40.h,
                                    ), // Space before white card
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        /// BOTTOM WHITE CARD (Expands to fill remaining screen)
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 32.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30.r),
                                topRight: Radius.circular(30.r),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Phone Number",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF374151),
                                  ),
                                ),
                                SizedBox(height: 8.h),

                                /// STYLED PHONE INPUT FIELD
                                _buildPhoneInputField(),

                                SizedBox(height: 32.h),

                                /// SEND OTP BUTTON
                                _buildSendOtpButton(context),

                                SizedBox(height: 32.h),

                                /// DIVIDER
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                      ),
                                      child: Text(
                                        "or",
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 32.h),

                                /// SIGN UP REDIRECT
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Get.to(() => SignUpScreen()),
                                      child: Text(
                                        "Sign Up",
                                        style: TextStyle(
                                          color: primaryGreen,
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                /// Extra padding at the bottom for completely safe scrolling
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).padding.bottom +
                                      20.h,
                                ),
                              ],
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
        },
      ),
    );
  }

  /// Extracted Phone Input Field Widget
  Widget _buildPhoneInputField() {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          /// COUNTRY PICKER
          Container(
            width: 100.w,
            alignment: Alignment.center,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: authCtrl.selectedCountry,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey.shade600,
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
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
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
          Container(height: 24.h, width: 1, color: Colors.grey.shade300),

          /// TEXT FIELD
          Expanded(
            child: TextField(
              controller: authCtrl.phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(fontSize: 15.sp, color: Colors.black87),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                hintText: "Enter phone number",
                hintStyle: TextStyle(
                  fontSize: 14.sp,
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
      height: 56.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          elevation: 2,
          shadowColor: primaryGreen.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
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
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Send OTP",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ],
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
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              24.w,
              14.h,
              24.w,
              MediaQuery.of(sheetContext).padding.bottom + 24.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// DRAG HANDLE
                Container(
                  width: 44.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                SizedBox(height: 24.h),

                /// ICON
                Container(
                  height: 72.h,
                  width: 72.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFDECEC),
                  ),
                  child: Icon(
                    Icons.person_search_rounded,
                    color: const Color(0xFFE05353),
                    size: 36.sp,
                  ),
                ),
                SizedBox(height: 20.h),

                /// TITLE
                Text(
                  "Account Not Found",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1F2937),
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 10.h),

                /// MESSAGE
                Text(
                  "We couldn't find an account for",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
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
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF374151),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),

                Text(
                  "Please check your number is correct, or create a new account to get started.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade500,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 28.h),

                /// SIGN UP BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      elevation: 2,
                      shadowColor: primaryGreen.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    onPressed: () {
                      Get.back();
                      Get.to(() => SignUpScreen());
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Create New Account",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                /// CHECK NUMBER AGAIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    onPressed: () => Get.back(),
                    child: Text(
                      "Check Number Again",
                      style: TextStyle(
                        color: const Color(0xFF374151),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
