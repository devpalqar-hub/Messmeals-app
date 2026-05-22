import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess/Screens/LoginScreen/Model/DistrictModel.dart';
import 'package:mess/Screens/LoginScreen/OtScreen.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:mess/Screens/LoginScreen/Service/SignUpController.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final AuthController authCtrl =
      Get.find<AuthController>();

  final TextEditingController
  nameController =
      TextEditingController();

  final TextEditingController
  emailController =
      TextEditingController();

  final TextEditingController
  messNameController =
      TextEditingController();

  final TextEditingController
  addressController =
      TextEditingController();
  final SignupController signupCtrl = Get.put(SignupController());


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF9F9F4),
      resizeToAvoidBottomInset: true,
     body: SafeArea(
  child: LayoutBuilder(
    builder: (context, constraints) {
      return SingleChildScrollView(
        keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.onDrag,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24.w,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Align(
                    alignment:
                        Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () =>
                          Get.back(),
                      icon: const Icon(
                        Icons.arrow_back,
                      ),
                    ),
                  ),

              
                  /// LOGO
                  Container(
                    width: 60.w,
                    height: 60.h,
                    decoration:
                        const BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          Color(0xFF569937),
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  SizedBox(height: 10.h),

                  Text(
                    "Create Account",
                    style:
                        GoogleFonts.inter(
                      fontSize: 22.sp,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: 2.h),

                  Text(
                    "Fill your details",
                    style:
                        GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: Colors.grey,
                    ),
                  ),

                  SizedBox(height: 18.h),

                  /// FORM CONTAINER
                  Container(
                    padding:
                        EdgeInsets.all(
                      16.w,
                    ),
                    decoration:
                        BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                        12.r,
                      ),
                      border: Border.all(
                        color: Colors
                            .grey.shade200,
                      ),
                    ),
                    child: Column(
                      children: [
                        _textField(
                          label: "Name",
                          controller:
                              nameController,
                          icon: Icons
                              .person_outline,
                        ),

                        SizedBox(
                            height: 8.h),

                        _phoneField(),

                        SizedBox(
                            height: 8.h),

                        _textField(
                          label:
                              "Email ID",
                          controller:
                              emailController,
                          icon: Icons
                              .email_outlined,
                        ),

                        SizedBox(
                            height: 8.h),

                        _textField(
                          label:
                              "Mess Name",
                          controller:
                              messNameController,
                          icon: Icons
                              .restaurant_menu,
                        ),

                        SizedBox(
                            height: 8.h),
                            _districtDropdown(),

SizedBox(height: 8.h),

                        _textField(
                          label:
                              "Address",
                          controller:
                              addressController,
                          icon: Icons
                              .location_on_outlined,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

               InkWell(
  onTap: () async {
  final phone = authCtrl.phoneController.text.trim();

  if (nameController.text.isEmpty ||
      emailController.text.isEmpty ||
      messNameController.text.isEmpty ||
      addressController.text.isEmpty ||
      phone.isEmpty ||
      signupCtrl.selectedDistrict == null) {
    Get.snackbar(
      "Error",
      "Please fill all fields",
    );
    return;
  }

  // SAVE VALUES IN CONTROLLER
  signupCtrl.name = nameController.text.trim();
  signupCtrl.ownerName = nameController.text.trim();
  signupCtrl.email = emailController.text.trim();
  signupCtrl.address = addressController.text.trim();
  signupCtrl.messName = messNameController.text.trim();

  final success = await signupCtrl.sendOtp(
    name: signupCtrl.name,
    ownerName: signupCtrl.ownerName,
    phone: phone,
    email: signupCtrl.email,
    address: signupCtrl.address,
    messName: signupCtrl.messName,
    district: signupCtrl.selectedDistrict!.name ?? "",
  );

  if (success) {
    Get.to(
      () => OtpVerificationScreen(
        phoneNumber: phone,
        isSignup: true,
      ),
    );
  }
},
  child: Container(
    height: 50.h,
    width: double.infinity,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14.r),
      color: const Color.fromARGB(255, 37, 55, 29),
    ),
    child: Text(
      "Send Otp",
      style: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),

                  SizedBox(height: 18.h),

                  /// LOGIN
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style:
                            GoogleFonts.inter(
                          fontSize:
                              14.sp,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Get.back(),
                        child: Text(
                          "Login",
                          style:
                              GoogleFonts.inter(
                            color:
                                const Color(
                              0xFF5AA63A,
                            ),
                            fontWeight:
                                FontWeight
                                    .w600,
                            fontSize:
                                14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 18.h),
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

  Widget _phoneField() {
  return Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      Text(
        "Phone Number",
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF111827),
        ),
      ),

      SizedBox(height: 5.h),

      Container(
        height: 45.h,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          borderRadius:
              BorderRadius.circular(
            14.r,
          ),
        ),
        child: Row(
          children: [
            /// COUNTRY PICKER
            SizedBox(
              width: 110.w,
              child:
                  DropdownButtonHideUnderline(
                child:
                    DropdownButton<String>(
                  value: authCtrl
                      .selectedCountry,
                  icon: const Icon(
                    Icons
                        .keyboard_arrow_down,
                  ),
                  items: [
                    "IN",
                    "US",
                    "AE"
                  ]
                      .map(
                        (item) =>
                            DropdownMenuItem(
                          value: item,
                          child: Row(
                            children: [
                              SizedBox(
                                  width:
                                      8.w),

                              SizedBox(
                                width:
                                    22.w,
                                height:
                                    16.h,
                                child:
                                    CountryPickerUtils.getDefaultFlagImage(
                                  CountryPickerUtils
                                      .getCountryByIsoCode(
                                    item,
                                  ),
                                ),
                              ),

                              SizedBox(
                                  width:
                                      6.w),

                              Text(
                                "+${CountryPickerUtils.getCountryByIsoCode(item).phoneCode}",
                                style:
                                    TextStyle(
                                  fontSize:
                                      14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),

                  onChanged: (
                    value,
                  ) {
                    if (value !=
                        null) {
                      authCtrl
                              .selectedCountry =
                          value;
                      authCtrl
                          .update();
                    }
                  },
                ),
              ),
            ),

            Container(
              height: 30.h,
              width: 1,
              color:
                  Colors.grey.shade300,
            ),

            SizedBox(width: 10.w),

            Expanded(
              child: TextField(
                controller: authCtrl
                    .phoneController,
                keyboardType:
                    TextInputType
                        .phone,
                decoration:
                    InputDecoration(
                  border:
                      InputBorder.none,
                  prefixIcon:
                      Icon(
                    Icons
                        .phone_outlined,
                    color:
                        Colors.grey,
                    size: 20.sp,
                  ),
                  contentPadding:
                      EdgeInsets.only(
                    top: 14.h,
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
Widget _textField({
  required String label,
  required TextEditingController controller,
  required IconData icon,
}) {
  return Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF111827),
        ),
      ),

      SizedBox(height: 5.h),

      Container(
        height: 45.h,
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          borderRadius:
              BorderRadius.circular(
            14.r,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.grey.shade600,
              size: 22,
            ),

            SizedBox(width: 10.w),

            Expanded(
              child: TextField(
                controller: controller,
                decoration:
                    const InputDecoration(
                  border:
                      InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
Widget _districtDropdown() {
  return GetBuilder<SignupController>(
    builder: (ctrl) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "District",
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 5.h),

          InkWell(
            onTap: () {
              _showDistrictBottomSheet(ctrl);
            },
            child: Container(
              height: 45.h,
              padding: EdgeInsets.symmetric(
                horizontal: 14.w,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
                borderRadius:
                    BorderRadius.circular(14.r),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ctrl.selectedDistrict?.name ??
                        "Select District",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color:
                          ctrl.selectedDistrict ==
                                  null
                              ? Colors.grey
                              : Colors.black,
                    ),
                  ),

                  const Icon(
                    Icons.keyboard_arrow_down,
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

void _showDistrictBottomSheet(
    SignupController ctrl) {
    
  ScrollController scrollController =
      ScrollController();

  scrollController.addListener(() {
    if (scrollController.position.pixels ==
            scrollController
                .position.maxScrollExtent &&
        ctrl.hasMore) {
      ctrl.fetchDistricts(
        loadMore: true,
      );
    }
  });

  Get.bottomSheet(
    Container(
      height: 450.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),

      child: GetBuilder<SignupController>(
        builder: (controller) {
          return ListView.builder(
            controller: scrollController,

            itemCount:
                controller.districtList.length +
                    (controller.hasMore
                        ? 1
                        : 0),

            itemBuilder:
                (context, index) {
              if (index ==
                  controller
                      .districtList.length) {
                return const Center(
                  child:
                      CircularProgressIndicator(),
                );
              }

              DistrictModel district =
                  controller
                          .districtList[
                      index];

              return ListTile(
                title: Text(
                  district.name ?? "",
                ),
                onTap: () {
                  controller
                      .selectDistrict(
                          district);

                  Get.back();
                },
              );
            },
          );
        },
      ),
    ),
  );
}}