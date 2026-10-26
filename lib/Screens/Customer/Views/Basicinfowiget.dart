import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dialog.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:mess/Screens/LoginScreen/Views/LocationPickerScreen.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class BasicInfoWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final TextEditingController locationController;
  final String selectedCountryIso;
  final ValueChanged<String> onCountryChanged;
  final String? pickedLocationLabel;
  final void Function(double lat, double lng, String? label) onLocationPicked;

  const BasicInfoWidget({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.addressController,
    required this.locationController,
    required this.selectedCountryIso,
    required this.onCountryChanged,
    required this.onLocationPicked,
    this.pickedLocationLabel,
  });

  @override
  Widget build(BuildContext context) {
    final selectedCountry = CountryPickerUtils.getCountryByIsoCode(
      selectedCountryIso,
    );

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

          phoneField(context, phoneController, selectedCountry),

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

          /// PIN ON MAP — precise coordinates the delivery partner's app
          /// relies on to actually find this customer; the address field
          /// above alone isn't enough for that.
          title("Pin Location on Map (Optional)"),

          SizedBox(height: 5.h),

          _locationPickerField(context),

          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _locationPickerField(BuildContext context) {
    final hasLocation = locationController.text.trim().isNotEmpty;
    final parts = locationController.text.split(',');
    LatLng? initial;
    if (parts.length == 2) {
      final lat = double.tryParse(parts[0]);
      final lng = double.tryParse(parts[1]);
      if (lat != null && lng != null) initial = LatLng(lat, lng);
    }

    return InkWell(
      onTap: () async {
        final picked = await Get.to<PickedLocation>(
          () => LocationPickerScreen(initialLocation: initial),
        );
        if (picked != null) {
          onLocationPicked(
            picked.latLng.latitude,
            picked.latLng.longitude,
            picked.placeName,
          );
        }
      },
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        height: 50.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: hasLocation ? AppColors.primary : const Color(0xffE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasLocation ? Icons.check_circle : Icons.map_outlined,
              color: hasLocation ? AppColors.primary : const Color(0xff6B7280),
              size: 18.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                hasLocation
                    ? (pickedLocationLabel?.isNotEmpty == true
                        ? pickedLocationLabel!
                        : locationController.text)
                    : "Tap to pin this customer on the map",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  color:
                      hasLocation
                          ? const Color(0xff111827)
                          : const Color(0xff9CA3AF),
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_right_rounded,
              color: const Color(0xff6B7280),
            ),
          ],
        ),
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

  Widget phoneField(
    BuildContext context,
    TextEditingController controller,
    Country country,
  ) {
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

          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (_) => CountryPickerDialog(
                      isSearchable: true,
                      titlePadding: EdgeInsets.all(16.w),
                      searchCursorColor: AppColors.primary,
                      searchInputDecoration: const InputDecoration(
                        hintText: 'Search country',
                      ),
                      priorityList: [
                        CountryPickerUtils.getCountryByIsoCode('IN'),
                      ],
                      title: Text(
                        'Select a country',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      onValuePicked:
                          (Country picked) => onCountryChanged(picked.isoCode),
                    ),
              );
            },
            child: Container(
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
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
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
