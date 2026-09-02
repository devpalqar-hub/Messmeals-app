import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess/Screens/HomeScreen/HomeView.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/LoginScreen/Service/SignUpController.dart';
import 'package:mess/Screens/Utils/AppColors.dart';
import 'package:mess/Screens/Utils/AppToast.dart';

/// Simple, minimal OTP verification screen — matches LoginScreen's plain
/// white background, flat brand-green accents, and no decorative chrome.
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
  final AuthController authCtrl = Get.put(AuthController());

  final List<TextEditingController> _otpCtrl = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());

  int _seconds = 45;
  int _resendCount = 0; // track how many times resend was tapped
  bool _isResending = false; // loading state for resend
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    // Back-off: 45s → 90s → 120s cap
    final duration =
        _resendCount == 0
            ? 45
            : _resendCount == 1
            ? 90
            : 120;
    setState(() => _seconds = duration);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) {
        t.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  String get _timerText {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _resendOtp() async {
    if (_seconds > 0 || _isResending) return;
    setState(() => _isResending = true);
    try {
      final ok = await authCtrl.sendOtp(widget.phoneNumber);
      if (ok) {
        // Clear all OTP boxes on resend
        for (var c in _otpCtrl) c.clear();
        FocusScope.of(context).requestFocus(_nodes[0]);
        _resendCount++;
        _startTimer();
        AppToast.success('OTP resent successfully');
      } else {
        AppToast.error('Failed to resend OTP. Please try again.');
      }
    } catch (e) {
      AppToast.error(e.toString());
    } finally {
      setState(() => _isResending = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _otpCtrl) c.dispose();
    for (var n in _nodes) n.dispose();
    super.dispose();
  }

  Widget _otpBox(int i) {
    return SizedBox(
      width: 44.w,
      height: 52.h,
      child: TextField(
        controller: _otpCtrl[i],
        focusNode: _nodes[i],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: GoogleFonts.poppins(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF111827),
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: false,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.primary, width: 1.6),
          ),
        ),
        onChanged: (v) {
          if (v.isNotEmpty) {
            if (i < 5)
              FocusScope.of(context).requestFocus(_nodes[i + 1]);
            else
              FocusScope.of(context).unfocus();
          } else {
            if (i > 0) FocusScope.of(context).requestFocus(_nodes[i - 1]);
          }
        },
      ),
    );
  }

  Future<void> _verify() async {
    final otp = _otpCtrl.map((e) => e.text).join();
    if (otp.length != 6) {
      AppToast.error('Please enter a valid 6-digit OTP');
      return;
    }
    try {
      if (widget.isSignup) {
        final sc = Get.find<SignupController>();
        final ok = await sc.signup(
          name: sc.name,
          ownerName: sc.ownerName,
          phone: widget.phoneNumber,
          email: sc.email,
          address: sc.address,
          messName: sc.messName,
          district: sc.selectedDistrict?.name ?? '',
          otp: otp,
        );
        if (ok) Get.offAll(() => DashboardScreen());
      } else {
        final ok = await authCtrl.verifyOtp(widget.phoneNumber, otp);
        if (ok) Get.offAll(() => DashboardScreen());
      }
    } catch (e) {
      AppToast.error(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18.sp,
            color: const Color(0xFF111827),
          ),
        ),
      ),
      body: GetBuilder<AuthController>(
        builder:
            (_) => SafeArea(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),

                    /// HEADING
                    Text(
                      'Verify your number',
                      style: GoogleFonts.poppins(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    RichText(
                      text: TextSpan(
                        text: 'We sent a 6-digit code to ',
                        style: GoogleFonts.poppins(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                        children: [
                          TextSpan(
                            text: widget.phoneNumber,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: GestureDetector(
                              onTap: () => Get.back(),
                              child: Padding(
                                padding: EdgeInsets.only(left: 6.w),
                                child: Icon(
                                  Icons.edit_outlined,
                                  size: 14.sp,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32.h),

                    Text(
                      'OTP Code',
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, _otpBox),
                    ),

                    SizedBox(height: 24.h),

                    /// Timer / Resend row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _seconds > 0
                              ? 'Resend code in $_timerText'
                              : "Didn't receive the code?",
                          style: GoogleFonts.poppins(
                            fontSize: 12.5.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        GestureDetector(
                          onTap: _resendOtp,
                          child:
                              _isResending
                                  ? SizedBox(
                                    width: 14.w,
                                    height: 14.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.8,
                                      color: AppColors.primary,
                                    ),
                                  )
                                  : Text(
                                    'Resend',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5.sp,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          _seconds == 0 && !_isResending
                                              ? AppColors.primaryDark
                                              : Colors.grey.shade300,
                                    ),
                                  ),
                        ),
                      ],
                    ),

                    SizedBox(height: 32.h),

                    /// VERIFY BUTTON
                    SizedBox(
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
                        onPressed: authCtrl.isLoading ? null : _verify,
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
                                  'Verify & Continue',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),

                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
