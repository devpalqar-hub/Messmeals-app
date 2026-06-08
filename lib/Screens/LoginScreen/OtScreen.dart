import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess/Screens/HomeScreen/HomeView.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/LoginScreen/Service/SignUpController.dart';
import 'package:mess/Screens/Utils/AppToast.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isSignup;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.isSignup = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final AuthController authCtrl = Get.find<AuthController>();

  /// Primary App Color
  final Color primaryGreen = const Color(0xFF5BA43A);

  /// OTP Controllers
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

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

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() {
          secondsRemaining--;
        });
      }
    });
  }

  /// TIMER FORMAT
  String get timerText {
    int min = secondsRemaining ~/ 60;
    int sec = secondsRemaining % 60;
    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  /// ENHANCED OTP BOX
  Widget otpBox(int index) {
    return Container(
      width: 48.w,
      height: 58.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: otpControllers[index],
        focusNode: focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: GoogleFonts.inter(
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF111827),
        ),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(color: primaryGreen, width: 2.0),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 5) {
              FocusScope.of(context).requestFocus(focusNodes[index + 1]);
            } else {
              FocusScope.of(context).unfocus();
            }
          } else {
            if (index > 0) {
              FocusScope.of(context).requestFocus(focusNodes[index - 1]);
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    for (var controller in otpControllers) controller.dispose();
    for (var node in focusNodes) node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Changed to true so the keyboard pushes content up naturally
      resizeToAvoidBottomInset: true,
      body: GetBuilder<AuthController>(
        builder: (_) {
          return SingleChildScrollView(
            child: Column(
              children: [
                /// HEADER SECTION WITH FADE GRADIENT
                Stack(
                  children: [
                    SizedBox(
                      height: 320.h,
                      width: double.infinity,
                      child: Image.asset(
                        "assets/verify.png",
                        fit: BoxFit.cover,
                      ),
                    ),

                    /// Gradient Overlay for a seamless transition into the white background
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.3),
                              Colors.white,
                            ],
                            stops: const [0.5, 0.8, 1.0],
                          ),
                        ),
                      ),
                    ),

                    /// STYLED FLOATING BACK BUTTON
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 15.h,
                      left: 20.w,
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Color(0xFF111827),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                /// TEXT HEADERS
                Text(
                  "Verify OTP",
                  style: GoogleFonts.inter(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "Enter the 6-digit code sent to",
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 12.h),

                /// STYLED PHONE NUMBER BADGE
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border.all(color: primaryGreen.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.phoneNumber,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Icon(
                          Icons.edit_square,
                          color: primaryGreen,
                          size: 18.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40.h),

                /// OTP INPUT ROW
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) => otpBox(index)),
                  ),
                ),

                SizedBox(height: 40.h),

                /// TIMER & RESEND LOGIC
                secondsRemaining == 0
                    ? GestureDetector(
                      onTap: () async {
                        bool success = await authCtrl.sendOtp(
                          widget.phoneNumber,
                        );
                        if (success) {
                          startTimer();
                        }
                      },
                      child: Text(
                        "Resend OTP",
                        style: GoogleFonts.inter(
                          color: primaryGreen,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: primaryGreen,
                        ),
                      ),
                    )
                    : RichText(
                      text: TextSpan(
                        text: "Resend OTP in ",
                        style: GoogleFonts.inter(
                          color: Colors.grey.shade500,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: timerText,
                            style: GoogleFonts.inter(
                              color: primaryGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                SizedBox(height: 30.h),

                /// VERIFY BUTTON
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 10.h,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        elevation: 3,
                        shadowColor: primaryGreen.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      onPressed:
                          authCtrl.isLoading
                              ? null
                              : () async {
                                String otp =
                                    otpControllers.map((e) => e.text).join();

                                if (otp.length != 6) {
                                  AppToast.error(
                                    "Please enter a valid 6-digit OTP",
                                  );
                                  return;
                                }

                                try {
                                  if (widget.isSignup) {
                                    final signupCtrl =
                                        Get.find<SignupController>();
                                    final success = await signupCtrl.signup(
                                      name: signupCtrl.name,
                                      ownerName: signupCtrl.ownerName,
                                      phone: widget.phoneNumber,
                                      email: signupCtrl.email,
                                      address: signupCtrl.address,
                                      messName: signupCtrl.messName,
                                      district:
                                          signupCtrl.selectedDistrict?.name ??
                                          "",
                                      otp: otp,
                                    );

                                    if (success) {
                                      Get.offAll(() => DashboardScreen());
                                    }
                                  } else {
                                    final success = await authCtrl.verifyOtp(
                                      widget.phoneNumber,
                                      otp,
                                    );

                                    if (success) {
                                      Get.offAll(() => DashboardScreen());
                                    }
                                  }
                                } catch (e) {
                                  AppToast.error(e.toString());
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
                              : Text(
                                "Verify & Continue",
                                style: GoogleFonts.inter(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30.h,
                ), // Extra padding for bottom screen safe area
              ],
            ),
          );
        },
      ),
    );
  }
}
