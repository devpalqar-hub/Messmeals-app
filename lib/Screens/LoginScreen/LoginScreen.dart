//import 'package:country_pickers/utils/utils.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/LoginScreen/OtScreen.dart';

import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/LoginScreen/SignUpScreen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final AuthController authCtrl = Get.put(AuthController());
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: GetBuilder<AuthController>(
        builder: (_) {
          return Stack(
            children: [
              /// TOP BACKGROUND IMAGE
              Container(
                height: 470.h,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/Firefly.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        // Colors.black.withOpacity(.75),
                        // const Color(0xFF003B2F).withOpacity(.85),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              /// MAIN CONTENT
              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 120.h),

                      /// HEADER SECTION
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 28.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// LOGO + TITLE
                            Row(
                              children: [
                                Container(
                                  height: 60.h,
                                  width: 60.w,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: const Icon(
                                    Icons.restaurant,
                                    size: 30,
                                    color: Color(0xFF5BA13A),
                                  ),
                                ),

                                SizedBox(width: 14.w),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Super",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          TextSpan(
                                            text: "Meals",
                                            style: TextStyle(
                                              color: const Color(0xFF69B34C),
                                              fontSize: 24.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Text(
                                      "ADMIN",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.sp,
                                        letterSpacing: 4,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            SizedBox(height: 40.h),

                            /// WELCOME TEXT
                            Text(
                              "Welcome Back",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            SizedBox(height: 8.h),

                            Text(
                              "Sign in to continue to your account",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 70.h),

                      /// WHITE CARD
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(minHeight: 420.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 30.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24.r),
                            topRight: Radius.circular(24.r),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Phone Number",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            SizedBox(height: 18.h),

                            /// PHONE FIELD
                            Container(
                              height: 60.h,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Row(
                                children: [
                                  /// COUNTRY PICKER
                                  SizedBox(
                                    width: 110.w,
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: authCtrl.selectedCountry,
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down,
                                        ),
                                        items:
                                            ["IN", "US", "AE"]
                                                .map(
                                                  (item) => DropdownMenuItem(
                                                    value: item,
                                                    child: Row(
                                                      children: [
                                                        SizedBox(width: 8.w),

                                                        SizedBox(
                                                          width: 22.w,
                                                          height: 16.h,
                                                          child: CountryPickerUtils.getDefaultFlagImage(
                                                            CountryPickerUtils.getCountryByIsoCode(
                                                              item,
                                                            ),
                                                          ),
                                                        ),

                                                        SizedBox(width: 6.w),

                                                        Text(
                                                          "+${CountryPickerUtils.getCountryByIsoCode(item).phoneCode}",
                                                          style: TextStyle(
                                                            fontSize: 14.sp,
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
                                  Container(
                                    height: 30.h,
                                    width: 1,
                                    color: Colors.grey.shade300,
                                  ),

                                  SizedBox(width: 10.w),

                                  Expanded(
                                    child: TextField(
                                      controller: authCtrl.phoneController,

                                      keyboardType: TextInputType.phone,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Enter your phone number",
                                        hintStyle: TextStyle(fontSize: 12.sp),
                                        prefixIcon: Icon(
                                          Icons.phone_outlined,
                                          color: Colors.grey,
                                          size: 20.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 28.h),

                            /// SEND OTP BUTTON
                            InkWell(
                              onTap:
                                  authCtrl.isLoading
                                      ? null
                                      : () async {
                                        String phone =
                                            authCtrl.phoneController.text
                                                .trim();
                                        // "${authCtrl.countryCode}${authCtrl.phoneController.text.trim()}";

                                        if (phone.isEmpty) {
                                          return;
                                        }

                                        bool success = await authCtrl.sendOtp(
                                          phone,
                                        );

                                        if (success) {
                                          Get.to(
                                            () => OtpVerificationScreen(
                                              phoneNumber:
                                                  authCtrl.phoneController.text
                                                      .trim(),
                                            ),
                                          );
                                        }
                                      },
                              child: Container(
                                height: 58.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.r),
                                  color: const Color(0xFF569937),
                                ),
                                child: Center(
                                  child:
                                      authCtrl.isLoading
                                          ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                          : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Send OTP",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 17.sp,
                                                ),
                                              ),
                                              SizedBox(width: 12.w),
                                              const Icon(
                                                Icons.arrow_forward,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                ),
                              ),
                            ),

                            SizedBox(height: 40.h),

                            /// OR
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(color: Colors.grey.shade300),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                  ),
                                  child: Text(
                                    "or",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: Colors.grey.shade300),
                                ),
                              ],
                            ),

                            SizedBox(height: 35.h),

                            /// SIGNUP
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: TextStyle(fontSize: 15.sp),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Get.to(() => SignUpScreen());
                                  },
                                  child: Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      color: const Color(0xFF569937),
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
