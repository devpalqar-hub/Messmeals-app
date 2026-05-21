import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends State<OtpVerificationScreen> {
  final AuthController authCtrl =
      Get.find<AuthController>();

  /// OTP Controllers
  final List<TextEditingController>
      otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  final List<FocusNode> focusNodes =
      List.generate(
    6,
    (index) => FocusNode(),
  );

  int secondsRemaining = 45;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  /// TIMER
  void startTimer() {
    timer?.cancel();

    setState(() {
      secondsRemaining = 45;
    });

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (secondsRemaining == 0) {
          timer.cancel();
        } else {
          setState(() {
            secondsRemaining--;
          });
        }
      },
    );
  }

  /// TIMER FORMAT
  String get timerText {
    int min = secondsRemaining ~/ 60;
    int sec = secondsRemaining % 60;

    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  /// OTP BOX
  Widget otpBox(int index) {
    return SizedBox(
      width: 48.w,
      height: 58.h,
      child: TextField(
        controller: otpControllers[index],
        focusNode: focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
          fontSize: 22.sp,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14.r),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14.r),
            borderSide: const BorderSide(
              color: Color(0xFF5BA43A),
              width: 1.5,
            ),
          ),
        ),

        /// OTP NEXT / PREVIOUS
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 5) {
              FocusScope.of(context)
                  .requestFocus(
                focusNodes[index + 1],
              );
            } else {
              FocusScope.of(context)
                  .unfocus();
            }
          } else {
            if (index > 0) {
              FocusScope.of(context)
                  .requestFocus(
                focusNodes[index - 1],
              );
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();

    for (var controller
        in otpControllers) {
      controller.dispose();
    }

    for (var node in focusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: GetBuilder<AuthController>(
        builder: (_) {
          return Column(
            children: [
              /// TOP SECTION
              Stack(
                children: [
                  Container(
                    height: 360.h,
                    width: double.infinity,
                    decoration:
                        const BoxDecoration(
                      gradient:
                          LinearGradient(
                        colors: [
                          Color(0xFF003D32),
                          Color(0xFF005D4A),
                        ],
                        begin:
                            Alignment.topLeft,
                        end: Alignment
                            .bottomRight,
                      ),
                    ),
                  ),

                  /// BACKGROUND IMAGE
                  Positioned.fill(
                    child: Opacity(
                      opacity: .15,
                      child: Image.asset(
                        "assets/images/login_bg.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  /// BACK BUTTON
                  Positioned(
                    top: 55.h,
                    left: 20.w,
                    child: GestureDetector(
                      onTap: () =>
                          Get.back(),
                      child: const Icon(
                        Icons.arrow_back,
                        color:
                            Colors.white,
                        size: 28,
                      ),
                    ),
                  ),

                  /// SHIELD IMAGE
                  Positioned(
                    top: 120.h,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 130.w,
                        height: 130.h,
                        decoration:
                            BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(
                                  100),
                        ),
                        child:
                            Image.asset(
                          "assets/images/shield.png",
                          fit:
                              BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  /// CURVE
                  Positioned(
                    bottom: -1,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 70.h,
                      decoration:
                          const BoxDecoration(
                        color:
                            Colors.white,
                        borderRadius:
                            BorderRadius.vertical(
                          top: Radius
                              .circular(
                            100,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              /// TITLE
              Text(
                "Verify OTP",
                style:
                    GoogleFonts.inter(
                  fontSize: 30.sp,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      const Color(
                    0xFF111827,
                  ),
                ),
              ),

              SizedBox(height: 10.h),

              Text(
                "Enter the 6-digit code sent to",
                style:
                    GoogleFonts.inter(
                  fontSize: 15.sp,
                  color: Colors
                      .grey.shade600,
                ),
              ),

              SizedBox(height: 8.h),

              /// PHONE NUMBER
              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [
                  Text(
                    widget.phoneNumber,
                    style:
                        GoogleFonts.inter(
                      fontWeight:
                          FontWeight
                              .w700,
                      fontSize: 18.sp,
                    ),
                  ),

                  SizedBox(
                      width: 10.w),

                  GestureDetector(
                    onTap: () =>
                        Get.back(),
                    child: Text(
                      "Change",
                      style:
                          GoogleFonts.inter(
                        color:
                            const Color(
                          0xFF5BA43A,
                        ),
                        fontWeight:
                            FontWeight
                                .w600,
                        fontSize:
                            16.sp,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 45.h),

              /// OTP BOXES
              Padding(
                padding:
                    EdgeInsets.symmetric(
                  horizontal: 24.w,
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children:
                      List.generate(
                    6,
                    (index) =>
                        otpBox(index),
                  ),
                ),
              ),

              SizedBox(height: 45.h),

              /// RESEND OTP
              secondsRemaining == 0
                  ? GestureDetector(
                      onTap:
                          () async {
                        bool success =
                            await authCtrl
                                .sendOtp(
                          widget
                              .phoneNumber,
                        );

                        if (success) {
                          startTimer();
                        }
                      },
                      child: Text(
                        "Resend OTP",
                        style:
                            GoogleFonts.inter(
                          color:
                              const Color(
                            0xFF5BA43A,
                          ),
                          fontSize:
                              16.sp,
                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                      ),
                    )
                  : RichText(
                      text: TextSpan(
                        text:
                            "Resend OTP in ",
                        style:
                            GoogleFonts.inter(
                          color:
                              Colors.grey,
                          fontSize:
                              16.sp,
                        ),
                        children: [
                          TextSpan(
                            text:
                                timerText,
                            style:
                                GoogleFonts.inter(
                              color:
                                  const Color(
                                0xFF5BA43A,
                              ),
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),
                        ],
                      ),
                    ),

              const Spacer(),

              /// VERIFY BUTTON
              Padding(
                padding:
                    EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 30.h,
                ),
                child: SizedBox(
                  width:
                      double.infinity,
                  height: 58.h,
                  child:
                      ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(
                        0xFF5BA43A,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          18.r,
                        ),
                      ),
                    ),
                    onPressed:
                        authCtrl
                                .isLoading
                            ? null
                            : () async {
                                String otp =
                                    otpControllers
                                        .map(
                                          (
                                            e,
                                          ) =>
                                              e
                                                  .text,
                                        )
                                        .join();

                                if (otp
                                        .length !=
                                    6) {
                                  Get.snackbar(
                                    "Error",
                                    "Please enter valid OTP",
                                  );
                                  return;
                                }

                                await authCtrl
                                    .verifyOtp(
                                  widget
                                      .phoneNumber,
                                  otp,
                                );
                              },
                    child: authCtrl
                            .isLoading
                        ? const CircularProgressIndicator(
                            color:
                                Colors
                                    .white,
                          )
                        : Text(
                            "Verify & Continue",
                            style:
                                GoogleFonts.inter(
                              fontSize:
                                  18.sp,
                              fontWeight:
                                  FontWeight
                                      .w600,
                              color:
                                  Colors
                                      .white,
                            ),
                          ),
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