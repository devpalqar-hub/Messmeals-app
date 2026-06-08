import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess/Screens/LoginScreen/Model/DistrictModel.dart';
import 'package:mess/Screens/LoginScreen/OtScreen.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:mess/Screens/LoginScreen/Service/SignUpController.dart';
import 'package:mess/Screens/Utils/AppToast.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final AuthController authCtrl = Get.find<AuthController>();
  final SignupController signupCtrl = Get.put(SignupController());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController messNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

  /// Primary App Color
  final Color primaryGreen = const Color(0xFF5BA43A);
  final Color inputFillColor = Colors.grey.shade50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar:
      /// SUBMIT BUTTON
      SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              elevation: 2,
              shadowColor: primaryGreen.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            onPressed: () => _handleSignup(),
            child: Text(
              "Send OTP",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Create Account",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// BACK BUTTON

                        /// HEADER SECTION (Logo + Titles)
                        // Row(
                        //   crossAxisAlignment: CrossAxisAlignment.center,
                        //   children: [
                        //     Container(
                        //       width: 54.w,
                        //       height: 54.w,
                        //       decoration: BoxDecoration(
                        //         shape: BoxShape.circle,
                        //         color: primaryGreen.withOpacity(0.15),
                        //       ),
                        //       child: Icon(
                        //         Icons.restaurant,
                        //         color: primaryGreen,
                        //         size: 28.sp,
                        //       ),
                        //     ),
                        //     SizedBox(width: 16.w),
                        //   Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [

                        //       SizedBox(height: 4.h),
                        //       Text(
                        //         "Fill your details to get started",
                        //         style: GoogleFonts.inter(
                        //           fontSize: 14.sp,
                        //           color: Colors.grey.shade500,
                        //           fontWeight: FontWeight.w500,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ],
                        // ),
                        SizedBox(height: 30.h),

                        /// FORM FIELDS
                        _textField(
                          label: "Full Name",
                          controller: nameController,
                          icon: Icons.person_outline_rounded,
                        ),
                        SizedBox(height: 16.h),

                        _phoneField(),
                        SizedBox(height: 16.h),

                        _textField(
                          label: "Email Address",
                          controller: emailController,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 16.h),

                        _textField(
                          label: "Mess Name",
                          controller: messNameController,
                          icon: Icons.storefront_outlined,
                        ),
                        SizedBox(height: 16.h),

                        // _districtDropdown(),
                        // SizedBox(height: 16.h),
                        _textField(
                          label: "Complete Address",
                          controller: addressController,
                          icon: Icons.location_on_outlined,
                        ),
                        SizedBox(height: 16.h),

                        _textField(
                          label: "Postal Code",
                          controller: pincodeController,
                          icon: Icons.numbers,
                          keyboardType: TextInputType.number,
                        ),

                        const Spacer(), // Pushes the button to the bottom

                        SizedBox(height: 20.h),

                        /// LOGIN REDIRECT
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: Text(
                                "Log In",
                                style: GoogleFonts.inter(
                                  color: primaryGreen,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// SUBMIT LOGIC HANDLER
  void _handleSignup() async {
    final phone = authCtrl.phoneController.text.trim();

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        messNameController.text.isEmpty ||
        addressController.text.isEmpty ||
        phone.isEmpty ||
        pincodeController.text.length < 5) {
      AppToast.show(
        title: "Missing Details",
        message: "Please fill all fields to continue",
      );
      return;
    }

    // SAVE VALUES IN CONTROLLER
    signupCtrl.name = nameController.text.trim();
    signupCtrl.ownerName = nameController.text.trim();
    signupCtrl.email = emailController.text.trim();
    signupCtrl.address = addressController.text.trim();
    signupCtrl.messName = messNameController.text.trim();
    signupCtrl.zipcode = pincodeController.text.trim();

    final success = await signupCtrl.sendOtp(
      name: signupCtrl.name,
      ownerName: signupCtrl.ownerName,
      phone: phone,
      email: signupCtrl.email,
      address: signupCtrl.address,
      messName: signupCtrl.messName,
      zipcode: signupCtrl.zipcode,
      // district: signupCtrl.selectedDistrict!.name ?? "",
    );

    if (success) {
      Get.to(() => OtpVerificationScreen(phoneNumber: phone, isSignup: true));
    }
  }

  /// STANDARDIZED TEXT FIELD
  Widget _textField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          height: 52.h,
          decoration: BoxDecoration(
            color: inputFillColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.inter(fontSize: 15.sp, color: Colors.black87),
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20.sp),
              contentPadding: EdgeInsets.symmetric(vertical: 16.h),
              hintText: "Enter $label",
              hintStyle: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// STANDARDIZED PHONE FIELD
  Widget _phoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Phone Number",
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          height: 52.h,
          decoration: BoxDecoration(
            color: inputFillColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              /// COUNTRY PICKER
              Container(
                width: 90.w,
                alignment: Alignment.center,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: authCtrl.selectedCountry,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey.shade600,
                      size: 20.sp,
                    ),
                    isDense: true,
                    items:
                        ["IN", "US", "AE"]
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 20.w,
                                      height: 14.h,
                                      child: CountryPickerUtils.getDefaultFlagImage(
                                        CountryPickerUtils.getCountryByIsoCode(
                                          item,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      "+${CountryPickerUtils.getCountryByIsoCode(item).phoneCode}",
                                      style: GoogleFonts.inter(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        authCtrl.selectedCountry = value;
                        authCtrl.update();
                      }
                    },
                  ),
                ),
              ),

              /// DIVIDER
              Container(height: 24.h, width: 1, color: Colors.grey.shade300),

              /// NUMBER INPUT
              Expanded(
                child: TextField(
                  controller: authCtrl.phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                    hintText: "98765 43210",
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// STANDARDIZED DISTRICT DROPDOWN
  Widget _districtDropdown() {
    return GetBuilder<SignupController>(
      builder: (ctrl) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "District",
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
            SizedBox(height: 6.h),
            InkWell(
              onTap: () => _showDistrictBottomSheet(ctrl),
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                height: 52.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: inputFillColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.map_outlined,
                      color: Colors.grey.shade500,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        ctrl.selectedDistrict?.name ?? "Select your district",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color:
                              ctrl.selectedDistrict == null
                                  ? Colors.grey.shade400
                                  : Colors.black87,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// BOTTOM SHEET (Unchanged logic, slightly cleaner UI)
  void _showDistrictBottomSheet(SignupController ctrl) {
    ScrollController scrollController = ScrollController();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          ctrl.hasMore) {
        ctrl.fetchDistricts(loadMore: true);
      }
    });

    Get.bottomSheet(
      Container(
        height: 500.h,
        padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "Select District",
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: GetBuilder<SignupController>(
                builder: (controller) {
                  return ListView.separated(
                    controller: scrollController,
                    itemCount:
                        controller.districtList.length +
                        (controller.hasMore ? 1 : 0),
                    separatorBuilder:
                        (_, __) =>
                            Divider(color: Colors.grey.shade100, height: 1),
                    itemBuilder: (context, index) {
                      if (index == controller.districtList.length) {
                        return Padding(
                          padding: EdgeInsets.all(16.h),
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      DistrictModel district = controller.districtList[index];

                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        title: Text(
                          district.name ?? "",
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                        onTap: () {
                          controller.selectDistrict(district);
                          Get.back();
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
