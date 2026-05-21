import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mess/Screens/LoginScreen/AuthController.dart';
import 'package:mess/Screens/LoginScreen/OtpScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController =
      TextEditingController();

  final AuthController authController =
      Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B4332),
      body: GetBuilder<AuthController>(
        builder: (controller) {
          return Stack(
            children: [
              /// TOP IMAGE
              SizedBox(
                height: 470.h,
                width: double.infinity,
                child: Image.asset(
                  "assets/images/login_bg.png",
                  fit: BoxFit.cover,
                ),
              ),

              /// DARK OVERLAY
              Container(
                height: 470.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.25),
                      Colors.black.withOpacity(0.55),
                    ],
                  ),
                ),
              ),

              /// CONTENT
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 430.h,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 30.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.r),
                      topRight: Radius.circular(40.r),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      /// LOGO
                      Row(
                        children: [
                          Container(
                            height: 42.h,
                            width: 42.w,
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFF2ECC71),
                              borderRadius:
                                  BorderRadius.circular(
                                      12.r),
                            ),
                            child: const Icon(
                              Icons.restaurant,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            "SuperMeals",
                            style: GoogleFonts.poppins(
                              fontSize: 24.sp,
                              fontWeight:
                                  FontWeight.w700,
                              color:
                                  const Color(0xFF1B4332),
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 28.h),

                      /// TITLE
                      Text(
                        "Get Started",
                        style: GoogleFonts.poppins(
                          fontSize: 28.sp,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              const Color(0xFF111111),
                        ),
                      ),

                      SizedBox(height: 8.h),

                      Text(
                        "Enter your mobile number to continue",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      SizedBox(height: 30.h),

                      /// PHONE LABEL
                      Text(
                        "Mobile Number",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight:
                              FontWeight.w500,
                          color:
                              const Color(0xFF111111),
                        ),
                      ),

                      SizedBox(height: 10.h),

                      /// PHONE FIELD
                      Container(
                        height: 62.h,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                                  16.r),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 18.w),

                            Text(
                              "🇮🇳",
                              style: TextStyle(
                                fontSize: 22.sp,
                              ),
                            ),

                            SizedBox(width: 8.w),

                            Text(
                              "+91",
                              style:
                                  GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),

                            SizedBox(width: 12.w),

                            Container(
                              width: 1,
                              height: 26.h,
                              color: Colors.grey
                                  .withOpacity(0.3),
                            ),

                            SizedBox(width: 12.w),

                            Expanded(
                              child: TextField(
                                controller:
                                    phoneController,
                                keyboardType:
                                    TextInputType
                                        .phone,
                                maxLength: 10,
                                decoration:
                                    InputDecoration(
                                  border:
                                      InputBorder
                                          .none,
                                  hintText:
                                      "Enter phone number",
                                  counterText: "",
                                  hintStyle:
                                      GoogleFonts
                                          .poppins(
                                    color: Colors
                                        .grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 28.h),

                      /// SEND OTP BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 58.h,
                        child: ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(
                            padding:
                                EdgeInsets.zero,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          18.r),
                            ),
                          ),
                          onPressed:
                              controller.isLoading
                                  ? null
                                  : () async {
                                      if (phoneController
                                              .text
                                              .trim()
                                              .length !=
                                          10) {
                                        Fluttertoast
                                            .showToast(
                                          msg:
                                              "Enter valid mobile number",
                                        );
                                        return;
                                      }

                                      final success =
                                          await controller
                                              .sendOtp(
                                        phoneController
                                            .text
                                            .trim(),
                                      );

                                      if (success) {
                                        Get.to(
                                          () =>
                                              OtpScreen(
                                            phone:
                                                phoneController
                                                    .text
                                                    .trim(),
                                          ),
                                        );
                                      }
                                    },
                          child: Ink(
                            decoration:
                                BoxDecoration(
                              gradient:
                                  const LinearGradient(
                                colors: [
                                  Color(
                                      0xFF27AE60),
                                  Color(
                                      0xFF2ECC71),
                                ],
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          18.r),
                            ),
                            child: Center(
                              child: controller
                                      .isLoading
                                  ? LoadingAnimationWidget
                                      .staggeredDotsWave(
                                      color:
                                          Colors
                                              .white,
                                      size: 28,
                                    )
                                  : Text(
                                      "Send OTP",
                                      style:
                                          GoogleFonts
                                              .poppins(
                                        color:
                                            Colors
                                                .white,
                                        fontWeight:
                                            FontWeight
                                                .w600,
                                        fontSize:
                                            16.sp,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 28.h),

                      /// DIVIDER
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.symmetric(
                                    horizontal:
                                        12.w),
                            child: Text(
                              "or",
                              style:
                                  GoogleFonts
                                      .poppins(
                                color:
                                    Colors.grey,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(),
                          ),
                        ],
                      ),

                      SizedBox(height: 24.h),

                      /// SIGNUP
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text:
                                "Don’t have an account? ",
                            style:
                                GoogleFonts
                                    .poppins(
                              color:
                                  Colors.grey,
                              fontSize: 14.sp,
                            ),
                            children: [
                              TextSpan(
                                text: "Sign Up",
                                style:
                                    GoogleFonts
                                        .poppins(
                                  color:
                                      const Color(
                                          0xFF27AE60),
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                ),
                              )
                            ],
                          ),
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