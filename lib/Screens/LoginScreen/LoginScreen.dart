import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController phoneController = TextEditingController();
  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  bool isOtpSent = false;
  bool isLoading = false;

  String get enteredOtp =>
      otpControllers.map((controller) => controller.text).join();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
            physics: const BouncingScrollPhysics(),
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
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// ---------- LOGO ----------
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

                  /// ---------- TITLE ----------
                  Text(
                    "SuperMeals Admin",
                    style: GoogleFonts.inter(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    isOtpSent
                        ? "Verify your phone number"
                        : "Sign in to your account",
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      color: const Color(0xff717182),
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  SizedBox(height: 32.h),

                  /// ---------- PHONE FIELD ----------
                  if (!isOtpSent) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Phone Number",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(
                      height: 48.h, // restored compact height
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: "Phone Number",
                          hintStyle: GoogleFonts.inter(fontSize: 14.sp),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 12.h,
                          ),
                        ),
                        style: GoogleFonts.inter(fontSize: 15.sp),
                      ),
                    ),
                  ],

                  /// ---------- OTP FIELDS ----------
                  if (isOtpSent) ...[
                    SizedBox(
                      height: 70.h,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 44.w,
                            height: 44.h,
                            child: TextField(
                              controller: otpControllers[index],
                              focusNode: focusNodes[index],
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 5) {
                                  FocusScope.of(context).nextFocus();
                                } else if (value.isEmpty && index > 0) {
                                  FocusScope.of(context).previousFocus();
                                }
                              },
                              maxLength: 1,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              cursorColor: const Color(0xFF0474B9),
                              decoration: InputDecoration(
                                counterText: "",
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                contentPadding: EdgeInsets.zero,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF0474B9),
                                    width: 1.5,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                              ),
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: 18.h),
                  ],
 SizedBox(height: 18.h),
                  /// ---------- BUTTON ----------
                  ElevatedButton(
                    onPressed: () async {
                      if (isLoading) return;
                      final phone = phoneController.text.trim();

                      if (!isOtpSent && (phone.isEmpty || phone.length != 10)) {
                        Get.snackbar(
                          "Error",
                          "Please enter a valid 10-digit phone number",
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }

                      setState(() => isLoading = true);

                      if (!isOtpSent) {
                        final sent = await authController.sendOtp(phone);
                        if (sent) setState(() => isOtpSent = true);
                      } else {
                        final otp = enteredOtp;
                        if (otp.length != 6) {
                          Get.snackbar(
                            "Error",
                            "Please enter a valid 6-digit OTP",
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          setState(() => isLoading = false);
                          return;
                        }
                        await authController.verifyOtp(phone, otp);
                      }

                      setState(() => isLoading = false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0474B9),
                      minimumSize: Size(double.infinity, 50.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: isLoading
                        ? SizedBox(
                            height: 22.h,
                            width: 22.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isOtpSent ? "Verify" : "Send OTP",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                  ),

                  SizedBox(height: 18.h),

                  /// ---------- CHANGE NUMBER ----------
                  if (isOtpSent)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isOtpSent = false;
                          for (var c in otpControllers) {
                            c.clear();
                          }
                        });
                      },
                      child: Text(
                        "Change Phone Number",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: Colors.black,
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
