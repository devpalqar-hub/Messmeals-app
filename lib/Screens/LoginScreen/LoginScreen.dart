import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Initialize the controller
  final AuthController authController = Get.put(AuthController());

  final TextEditingController phoneController = TextEditingController();
  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  bool isOtpSent = false;

  String get enteredOtp => otpControllers.map((c) => c.text).join();

  @override
  void dispose() {
    phoneController.dispose();
    for (final c in otpControllers) c.dispose();
    for (final f in focusNodes) f.dispose();
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
                 
                  Container(
                    height: 55.h,
                    width: 55.w,
                    decoration: BoxDecoration(
                      color:  Colors.black,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: const Icon(Icons.restaurant, color: Colors.white),
                  ),
                  SizedBox(height: 16.h),

                 
                  Text(
                    "SuperMeals Admin",
                    style: GoogleFonts.inter(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6.h),

                  Text(
                    isOtpSent ? "Verify your phone number" : "Sign in to your account",
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      color: const Color(0xff717182),
                    ),
                  ),
                  SizedBox(height: 32.h),

                
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
                        enabled: true,
                      ),
                    ),
                  ],

                 
                if (isOtpSent) ...[
  SizedBox(height: 12.h),

  Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: List.generate(6, (index) {
      return SizedBox(
        width: 46.w,
        height: 46.w, // 🔥 perfect square
        child: TextField(
          controller: otpControllers[index],
          focusNode: focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center, // 🔥 vertical center
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
          maxLength: 1,
          onChanged: (value) {
            if (value.isNotEmpty && index < 5) {
              focusNodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              focusNodes[index - 1].requestFocus();
            }
          },
          decoration: InputDecoration(
            counterText: "",
            filled: true,
            fillColor: Colors.grey.shade100,

            // 🔥 IMPORTANT FIX FOR CENTERING
            contentPadding: EdgeInsets.zero,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide.none,
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(
                color: Colors.black,
                width: 1.5,
              ),
            ),
          ),
        ),
      );
    }),
  ),
],

                  SizedBox(height: 24.h),

                
                  GetBuilder<AuthController>(
                    builder: (auth) {
                      return ElevatedButton(
                        onPressed: auth.isLoading
                            ? null
                            : () async {
                                final phone = phoneController.text.trim();

                                if (!isOtpSent) {
                                  if (phone.length != 10) {
                                  
                                    return;
                                  }

                                  final success = await auth.sendOtp(phone);
                                  if (success) {
                                    setState(() => isOtpSent = true);
                                  }
                                } else {
                                  final otp = enteredOtp;
                                  if (otp.length != 6) {
                                   
                                    return;
                                  }

                                  final verified = await auth.verifyOtp(phone, otp);
                                  if (verified) {
                                    Fluttertoast.showToast(msg: "OTP verified successfully");
                                  } else {
                                    Fluttertoast.showToast(msg: "Invalid OTP");
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:  Colors.black,
                          minimumSize: Size(double.infinity, 50.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: auth.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                isOtpSent ? "Verify OTP" : "Send OTP",
                                style: const TextStyle(color: Colors.white),
                              ),
                      );
                    },
                  ),

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
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
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