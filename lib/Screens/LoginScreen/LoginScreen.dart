import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:pinput/pinput.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = Get.put(AuthController());

  final TextEditingController phoneController = TextEditingController();

  bool isOtpSent = false;

  @override
  void dispose() {
    phoneController.dispose(); // ✅ only this needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
            child: Container(
              width: 340.w,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 10.r,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  /// Logo
                  Container(
                    height: 55.h,
                    width: 55.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0073CF),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: const Icon(Icons.restaurant, color: Colors.white),
                  ),

                  SizedBox(height: 16.h),

                  /// Title
                  Text(
                    "SuperMeals Admin",
                    style: GoogleFonts.inter(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 6.h),

                  /// Subtitle
                  Text(
                    isOtpSent
                        ? "Verify your phone number"
                        : "Sign in to your account",
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      color: const Color(0xff717182),
                    ),
                  ),

                  SizedBox(height: 32.h),

                  /// Phone input
                  if (!isOtpSent) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Phone Number",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(
                      height: 48.h,
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: InputDecoration(
                          counterText: "",
                          hintText: "Enter phone number",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],

                  /// OTP Pinput (NEW)
                  if (isOtpSent) ...[
                    SizedBox(height: 10.h),
                    SizedBox(
                      height: 55.h,
                      child: Pinput(
                        length: 6,
                        keyboardType: TextInputType.number,

                        onCompleted: (otp) async {
                          final phone = phoneController.text.trim();

                          final verified =
                          await authController.verifyOtp(phone, otp);

                          if (verified) {
                            Fluttertoast.showToast(
                                msg: "OTP verified successfully");
                          } else {
                            Fluttertoast.showToast(msg: "Invalid OTP");
                          }
                        },
                      ),
                    ),
                  ],

                  SizedBox(height: 24.h),

                  /// Button → only SEND OTP
                  Obx(() => ElevatedButton(
                    onPressed: authController.isLoading.value
                        ? null
                        : () async {
                      final phone = phoneController.text.trim();

                      if (phone.length != 10) {
                        Fluttertoast.showToast(
                            msg: "Enter valid phone number");
                        return;
                      }

                      final success =
                      await authController.sendOtp(phone);

                      if (success) {
                        setState(() {
                          isOtpSent = true;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0474B9),
                      minimumSize: Size(double.infinity, 50.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: authController.isLoading.value
                        ? const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    )
                        : const Text(
                      "Send OTP",
                      style: TextStyle(color: Colors.white),
                    ),
                  )),

                  /// Change phone
                  if (isOtpSent)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isOtpSent = false;
                        });
                      },
                      child: Text(
                        "Change Phone Number",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
