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

  // For OTP boxes
  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());

  bool isOtpSent = false;
  bool isLoading = false;

  String get enteredOtp =>
      otpControllers.map((controller) => controller.text).join();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            height: 380.h,
            width: 360.h,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo or Icon
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0073CF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.restaurant, color: Colors.white),
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  "SuperMeals Admin",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  isOtpSent
                      ? "Verify your phone number"
                      : "Sign in to your account",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: const Color(0xff717182),
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 32),

                // Phone Field with label above
                if (!isOtpSent) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Phone Number",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: "9456006594",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],

                // OTP Field (6 boxes)
                if (isOtpSent)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 44.w,
                          height: 54.h,
                          child: TextField(
                            controller: otpControllers[index],
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                FocusScope.of(context).nextFocus();
                              }
                              if (value.isEmpty && index > 0) {
                                FocusScope.of(context).previousFocus();
                              }
                            },
                            maxLength: 1,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              counterText: "",
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide.none,
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

                const SizedBox(height: 24),

                // Button
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
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isOtpSent ? "Verify" : "Send OTP",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                ),

                const SizedBox(height: 16),

                // Change phone number
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
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
