import 'package:country_pickers/country.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class BasicInfoWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final TextEditingController locationController;

  const BasicInfoWidget({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.addressController,
    required this.locationController,
  });

  @override
  Widget build(BuildContext context) {
    Country selectedCountry = CountryPickerUtils.getCountryByIsoCode("IN");

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// BASIC INFO HEADER
          Row(
            children: [
              Container(
                height: 45.h,
                width: 45.w,
                decoration: BoxDecoration(
                  color: const Color(0xffE7F4F2),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ),

              SizedBox(width: 14.w),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Basic Information",
                    style: TextStyle(
                      fontSize: 16.sp,
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

          SizedBox(height: 24.h),

          /// FULL NAME
          title("Full Name *"),

          SizedBox(height: 5.h),

          textField(
            controller: nameController,
            hint: "Enter full name",
            icon: Icons.person_outline,
          ),

          SizedBox(height: 15.h),

          /// PHONE
          title("Phone Number *"),

          SizedBox(height: 5.h),

          phoneField(phoneController, selectedCountry),

          SizedBox(height: 15.h),

          /// EMAIL
          title("Email (Optional)"),

          SizedBox(height: 5.h),

          textField(
            controller: emailController,
            hint: "Enter email address",
            icon: Icons.email_outlined,
          ),

          SizedBox(height: 15.h),

          /// ADDRESS
          title("Address *"),

          SizedBox(height: 5.h),

          textField(
            controller: addressController,
            hint: "Enter full address",
            icon: Icons.location_on_outlined,
          ),

          SizedBox(height: 15.h),

          /// CURRENT LOCATION
          //  title("Current Location (Optional)"),

          // SizedBox(height: 5.h),

          // Container(
          //   height: 45.h,
          //   padding: EdgeInsets.symmetric(horizontal: 14.w),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(14.r),
          //     border: Border.all(color: const Color(0xffE5E7EB)),
          //   ),
          //   child: Row(
          //     children: [
          //       Icon(
          //         Icons.my_location_outlined,
          //         color: const Color(0xff6B7280),
          //         size: 22.sp,
          //       ),

          //       SizedBox(width: 12.w),

          //       Expanded(
          //         child: Text(
          //           "Use current location",
          //           style: TextStyle(
          //             fontSize: 14.sp,
          //             color: const Color(0xff6B7280),
          //           ),
          //         ),
          //       ),

          //       InkWell(
          //         onTap: () {},
          //         child: Container(
          //           height: 34.h,
          //           width: 34.h,
          //           decoration: BoxDecoration(
          //             color: AppColors.primary.withOpacity(0.15),
          //             borderRadius: BorderRadius.circular(10.r),
          //           ),
          //           child: Icon(
          //             Icons.gps_fixed,
          //             color: AppColors.primary,
          //             size: 18.sp,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          // SizedBox(height: 20.h),

          // /// OR DIVIDER
          // Row(
          //   children: [
          //     Expanded(child: Divider(color: Colors.grey.shade300)),

          //     Padding(
          //       padding: EdgeInsets.symmetric(horizontal: 12.w),
          //       child: Text(
          //         "or",
          //         style: TextStyle(
          //           color: const Color(0xff6B7280),
          //           fontSize: 14.sp,
          //         ),
          //       ),
          //     ),

          //     Expanded(child: Divider(color: Colors.grey.shade300)),
          //   ],
          // ),

          // SizedBox(height: 20.h),

          // /// LAT LONG
          // textField(
          //   controller: locationController,
          //   hint: "Enter latitude, longitude",
          //   icon: Icons.map_outlined,
          // ),

          // SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget title(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
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
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xff6B7280), size: 18.sp),

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

  Widget phoneField(TextEditingController controller, Country country) {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.call_outlined,
            color: const Color(0xff6B7280),
            size: 18.sp,
          ),

          SizedBox(width: 10.w),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xffF3F4F6),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Text(
                  "+${country.phoneCode}",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                Icon(Icons.keyboard_arrow_down, size: 18.sp),
              ],
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: "Enter phone number",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
