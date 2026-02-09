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
  final AuthController authController = Get.put(AuthController());

  final TextEditingController phoneController = TextEditingController();
  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes =
      List.generate(6, (_) => FocusNode());

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
                      color: const Color(0xFF0073CF),
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
                    isOtpSent
                        ? "Verify your phone number"
                        : "Sign in to your account",
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
                        enabled: !isOtpSent,
                      ),
                    ),
                  ],

                
                  if (isOtpSent) ...[
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 44.w,
                          height: 44.h,
                          child: TextField(
                            controller: otpControllers[index],
                            focusNode: focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0474B9),
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

                  Obx(() => ElevatedButton(
                        onPressed: authController.isLoading.value
                            ? null
                            : () async {
                                final phone = phoneController.text.trim();

                                if (!isOtpSent) {
                                  if (phone.length != 10) {
                                    Get.snackbar(
                                      "Error",
                                      "Enter valid 10-digit phone number",
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                    return;
                                  }

                                  final success =
                                      await authController.sendOtp(phone);

                                  if (success) {
                                    setState(() {
                                      isOtpSent = true;
                                    });
                                  }
                                }

                         
                                else {
                                  final otp = enteredOtp;

                                  if (otp.length != 6) {
                                    Get.snackbar(
                                      "Error",
                                      "Enter valid 6-digit OTP",
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                    return;
                                  }

                                  final verified = await authController
                                      .verifyOtp(phone, otp);

                                
                                  if (verified) {
                                    Fluttertoast.showToast(
                                      msg: "OTP verified successfully",
                                      toastLength: Toast.LENGTH_SHORT,
                                    );
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: "Invalid OTP",
                                      toastLength: Toast.LENGTH_SHORT,
                                    );
                                  }
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
                            : Text(isOtpSent ? "Verify OTP" : "Send OTP",style: TextStyle(color: Colors.white),),
                      )),

                  
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
