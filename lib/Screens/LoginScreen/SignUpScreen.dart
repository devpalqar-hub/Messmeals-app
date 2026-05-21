
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:country_pickers/utils/utils.dart';

class CreateAccountScreen extends StatelessWidget {
  CreateAccountScreen({super.key});

  final AuthController authCtrl = Get.find<AuthController>();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController messNameController =
      TextEditingController();

  final List<String> districts = [
    "Kozhikode",
    "Malappuram",
    "Thrissur",
    "Ernakulam",
    "Kannur",
    "Palakkad",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F4),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Column(
              children: [
                SizedBox(height: 12.h),

                /// BACK BUTTON
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                /// LOGO
                Container(
                  width: 85.w,
                  height: 85.h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF5AA63A),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: Colors.white,
                    size: 42,
                  ),
                ),

                SizedBox(height: 20.h),

                /// TITLE
                Text(
                  "Create Account",
                  style: GoogleFonts.inter(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  "Fill in your details to get started",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    color: Colors.grey.shade500,
                  ),
                ),

                SizedBox(height: 35.h),

                /// CARD
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(22.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(28.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12
                            .withOpacity(.03),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      /// PHONE
                      _title("Phone Number"),

                      SizedBox(height: 10.h),

                      _phoneField(),

                      SizedBox(height: 26.h),

                      /// EMAIL
                      _title("Email ID"),

                      SizedBox(height: 10.h),

                      _textField(
                        controller: emailController,
                        hint: "Enter your email address",
                        icon: Icons.email_outlined,
                      ),

                      SizedBox(height: 26.h),

                      /// MESS NAME
                      _title("Mess Name"),

                      SizedBox(height: 10.h),

                      _textField(
                        controller: messNameController,
                        hint: "Enter mess name",
                        icon: Icons.home_work_outlined,
                      ),

                      SizedBox(height: 26.h),

                      /// DISTRICT
                      _title("District"),

                      SizedBox(height: 10.h),

                      GetBuilder<AuthController>(
                        builder: (_) {
                          return Container(
                            height: 58.h,
                            padding: EdgeInsets.symmetric(
                                horizontal: 18.w),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey
                                    .shade300,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                      16.r),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: null,
                                hint: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      color: Colors
                                          .grey.shade600,
                                    ),
                                    SizedBox(width: 12.w),
                                    Text(
                                      "Select your district",
                                      style:
                                          GoogleFonts.inter(
                                        color: Colors
                                            .grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                ),
                                items: districts
                                    .map(
                                      (e) =>
                                          DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {},
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 35.h),

                      /// SEND OTP BUTTON
                      InkWell(
                        onTap: () async {
                          if (authCtrl
                              .phoneController
                              .text
                              .trim()
                              .isEmpty) {
                            Get.snackbar(
                              "Error",
                              "Enter phone number",
                            );
                            return;
                          }

                          await authCtrl.sendOtp(
                            authCtrl
                                .phoneController.text
                                .trim(),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 58.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(
                                    16.r),
                            gradient:
                                const LinearGradient(
                              colors: [
                                Color(0xFF5FAE3F),
                                Color(0xFF004B26),
                              ],
                            ),
                          ),
                          child: Text(
                            "Send OTP",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30.h),

                /// LOGIN
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Text(
                        "Login",
                        style: GoogleFonts.inter(
                          color:
                              const Color(0xFF5AA63A),
                          fontWeight:
                              FontWeight.w600,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 25.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _title(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF111827),
      ),
    );
  }

  Widget _phoneField() {
    return Container(
      height: 58.h,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius:
            BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100.w,
            child: DropdownButton(
              value: "IN",
              underline: const SizedBox(),
              icon: const SizedBox(),
              items: [
                DropdownMenuItem(
                  value: "IN",
                  child: Row(
                    children: [
                      SizedBox(width: 14.w),
                      SizedBox(
                        width: 22.w,
                        child:
                           CountryPickerUtils.getDefaultFlagImage(
  CountryPickerUtils.getCountryByIsoCode("IN"),
)
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        "+91",
                        style:
                            GoogleFonts.inter(
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              onChanged: (_) {},
            ),
          ),

          Container(
            width: 1,
            height: 28.h,
            color: Colors.grey.shade300,
          ),

          SizedBox(width: 12.w),

          const Icon(
            Icons.phone_outlined,
            color: Colors.grey,
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: TextField(
              controller:
                  authCtrl.phoneController,
              keyboardType:
                  TextInputType.phone,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText:
                    "Enter your phone number",
                hintStyle:
                    GoogleFonts.inter(
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController
        controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      height: 58.h,
      padding:
          EdgeInsets.symmetric(horizontal: 18.w),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius:
            BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey.shade600,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle:
                    GoogleFonts.inter(
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}