import 'package:country_pickers/country.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/Customer/PlanWallet.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  Country selectedCountry =
      CountryPickerUtils.getCountryByIsoCode("IN");

  int currentStep = 1;

  final Color primary = const Color(0xff0B8A7B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 10.h),

              /// TOP BAR
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.arrow_back,
                      size: 24.sp,
                      color: Colors.black,
                    ),
                  ),

                  Expanded(
                    child: Center(
                      child: Text(
                        "Add Customer",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff111827),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 24.w),
                ],
              ),

              SizedBox(height: 28.h),

              /// STEP INDICATOR
              Row(
                children: [
                  buildStep(
                    number: "1",
                    title: "Basic Info",
                    active: true,
                  ),

                  buildLine(),

                  buildStep(
                    number: "2",
                    title: "Plan & Wallet",
                  ),

                  buildLine(),

                  buildStep(
                    number: "3",
                    title: "Schedule",
                  ),

                  buildLine(),

                  buildStep(
                    number: "4",
                    title: "Review",
                  ),
                ],
              ),

              SizedBox(height: 32.h),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// BASIC INFO CARD
                      Row(
                        children: [
                          Container(
                            height: 52.h,
                            width: 52.h,
                            decoration: BoxDecoration(
                              color: const Color(0xffE7F4F2),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Icon(
                              Icons.person_outline,
                              color: primary,
                              size: 24.sp,
                            ),
                          ),

                          SizedBox(width: 14.w),

                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Basic Information",
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xff111827),
                                ),
                              ),

                              SizedBox(height: 4.h),

                              Text(
                                "Enter customer basic details",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xff6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 30.h),

                      /// FULL NAME
                      title("Full Name *"),

                      SizedBox(height: 10.h),

                      textField(
                        controller: nameController,
                        hint: "Enter full name",
                        icon: Icons.person_outline,
                      ),

                      SizedBox(height: 22.h),

                      /// PHONE
                      title("Phone Number *"),

                      SizedBox(height: 10.h),

                      phoneField(),

                      SizedBox(height: 22.h),

                      /// EMAIL
                      title("Email (Optional)"),

                      SizedBox(height: 10.h),

                      textField(
                        controller: emailController,
                        hint: "Enter email address",
                        icon: Icons.email_outlined,
                      ),

                      SizedBox(height: 22.h),

                      /// ADDRESS
                      title("Address *"),

                      SizedBox(height: 10.h),

                      textField(
                        controller: addressController,
                        hint: "Enter full address",
                        icon: Icons.location_on_outlined,
                      ),

                      SizedBox(height: 22.h),

                      /// LOCATION
                      title("Current Location (Optional)"),

                      SizedBox(height: 10.h),

                      Container(
                        height: 56.h,
                        padding:
                            EdgeInsets.symmetric(horizontal: 14.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(14.r),
                          border: Border.all(
                            color: const Color(0xffE5E7EB),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.my_location_outlined,
                              color: const Color(0xff6B7280),
                              size: 22.sp,
                            ),

                            SizedBox(width: 12.w),

                            Expanded(
                              child: Text(
                                "Use current location",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xff6B7280),
                                ),
                              ),
                            ),

                            Container(
                              height: 34.h,
                              width: 34.h,
                              decoration: BoxDecoration(
                                color:
                                    primary.withOpacity(0.15),
                                borderRadius:
                                    BorderRadius.circular(10.r),
                              ),
                              child: Icon(
                                Icons.gps_fixed,
                                color: primary,
                                size: 18.sp,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.h),

                      /// OR
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey.shade300,
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w),
                            child: Text(
                              "or",
                              style: TextStyle(
                                color: const Color(0xff6B7280),
                                fontSize: 14.sp,
                              ),
                            ),
                          ),

                          Expanded(
                            child: Divider(
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      /// LAT LONG
                      textField(
                        controller: locationController,
                        hint: "Enter latitude, longitude",
                        icon: Icons.map_outlined,
                      ),

                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),

              /// CONTINUE BUTTON
              Container(
                width: double.infinity,
                height: 56.h,
                margin: EdgeInsets.only(bottom: 14.h),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14.r),
                    ),
                  ),
                  onPressed: () { Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Step2PlanWallet(),
      ),
    );},
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        "Continue",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(width: 8.w),

                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLine() {
    return Expanded(
      child: Container(
        height: 1.5,
        color: const Color(0xffD1D5DB),
      ),
    );
  }

  Widget buildStep({
    required String number,
    required String title,
    bool active = false,
  }) {
    return Column(
      children: [
        Container(
          height: 34.h,
          width: 34.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? primary
                : Colors.white,
            border: Border.all(
              color: active
                  ? primary
                  : const Color(0xffD1D5DB),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: TextStyle(
              color: active
                  ? Colors.white
                  : const Color(0xff374151),
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
            ),
          ),
        ),

        SizedBox(height: 8.h),

        Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight:
                active ? FontWeight.w700 : FontWeight.w500,
            color: active
                ? primary
                : const Color(0xff6B7280),
          ),
        ),
      ],
    );
  }

  Widget title(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xff111827),
      ),
    );
  }

  Widget textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: const Color(0xffE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xff6B7280),
            size: 22.sp,
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(fontSize: 14.sp),
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(
                  color: const Color(0xff6B7280),
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget phoneField() {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: const Color(0xffE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.call_outlined,
            color: const Color(0xff6B7280),
            size: 22.sp,
          ),

          SizedBox(width: 10.w),

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 6.h,
            ),
            decoration: BoxDecoration(
              color: const Color(0xffF3F4F6),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Text(
                  "+91",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                Icon(
                  Icons.keyboard_arrow_down,
                  size: 18.sp,
                ),
              ],
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: "Enter phone number",
                hintStyle: TextStyle(
                  color: const Color(0xff6B7280),
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}