// DELIVERY PARTNER MODULE — DISABLED (admin-only build for now)
// Entire file commented out below; not wired into the app.
/*
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess/Screens/DeliveryPartner/Profile/Service/DeliveryProfileController.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class EditDeliveryProfileScreen extends StatefulWidget {
  const EditDeliveryProfileScreen({super.key});

  @override
  State<EditDeliveryProfileScreen> createState() => _EditDeliveryProfileScreenState();
}

class _EditDeliveryProfileScreenState extends State<EditDeliveryProfileScreen> {
  final DeliveryProfileController controller = Get.find<DeliveryProfileController>();

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final vehicleNumberCtrl = TextEditingController();
  String vehicleType = 'Two Wheeler';

  @override
  void initState() {
    super.initState();
    final profile = controller.profile;
    nameCtrl.text = profile?.name ?? '';
    phoneCtrl.text = profile?.phone ?? '';
    vehicleType = profile?.vehicleType ?? 'Two Wheeler';
    vehicleNumberCtrl.text = profile?.vehicleNumber ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DeliveryProfileController>(
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Color(0xFF111827)),
            title: Text(
              "Edit Profile",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
              child: SizedBox(
                height: 45.h,
                child: ElevatedButton(
                  onPressed:
                      ctrl.isSaving
                          ? null
                          : () async {
                            if (nameCtrl.text.trim().isEmpty) {
                              Fluttertoast.showToast(msg: "Please enter your name");
                              return;
                            }
                            final success = await controller.updateProfile(
                              name: nameCtrl.text.trim(),
                              phone: phoneCtrl.text.trim(),
                              vehicleType: vehicleType,
                              vehicleNumber: vehicleNumberCtrl.text.trim(),
                            );
                            if (success) Get.back();
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                  child:
                      ctrl.isSaving
                          ? SizedBox(
                            height: 22.h,
                            width: 22.w,
                            child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                          : Text(
                            "Save Changes",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          height: 84.w,
                          width: 84.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            nameCtrl.text.isNotEmpty ? nameCtrl.text[0].toUpperCase() : '?',
                            style: GoogleFonts.poppins(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.camera_alt, size: 14.sp, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  _label("Name"),
                  SizedBox(height: 8.h),
                  _field(controller: nameCtrl),

                  SizedBox(height: 16.h),
                  _label("Phone Number"),
                  SizedBox(height: 8.h),
                  _field(controller: phoneCtrl, keyboardType: TextInputType.phone),

                  SizedBox(height: 16.h),
                  _label("Vehicle Type"),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: vehicleType,
                        items:
                            ['Two Wheeler', 'Bicycle', 'Three Wheeler', 'Four Wheeler']
                                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                                .toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => vehicleType = value);
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),
                  _label("Vehicle Number"),
                  SizedBox(height: 8.h),
                  _field(controller: vehicleNumberCtrl, hint: "KL 07 AB 1234"),

                  SizedBox(height: 12.h),
                  Text(
                    "Vehicle details are stored on this device only until the backend adds support for them.",
                    style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w500),
    );
  }

  Widget _field({
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.primary, width: 1.2),
        ),
      ),
    );
  }
}

*/
