import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/HomeScreen/Views/AddMessBottomSheet.dart';
import 'package:mess/Screens/SettingsScreen/MessProfileSettingsScreen.dart';
import 'package:mess/Screens/Utils/Colors.dart';

class SelectMessBottomsheet extends StatefulWidget {
  SelectMessBottomsheet({super.key});

  @override
  State<SelectMessBottomsheet> createState() => _SelectMessBottomsheetState();
}

class _SelectMessBottomsheetState extends State<SelectMessBottomsheet> {
  HomeScreenController ctrl = Get.find();

  String? tempSelectedId;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tempSelectedId = ctrl.selectedMessId;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Mess",
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),
          // List of available Messes
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: ctrl.messes.length,
              itemBuilder: (context, index) {
                final mess = ctrl.messes[index];
                return RadioListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: PrimaryColor,
                  title: Text(
                    mess.name ?? "Unnamed Mess",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  value: mess.id,
                  groupValue: tempSelectedId,
                  onChanged: (value) {
                    setState(() {
                      tempSelectedId = value;
                    });
                  },
                );
              },
            ),
          ),
          Divider(color: Colors.grey.withOpacity(0.3)),
          // Add Mess Button
          InkWell(
            onTap: () {
              Get.back();
              Get.to(
                () => const MessProfileSettingsScreen(forceCreate: true),
                transition: Transition.rightToLeft,
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline, color: PrimaryColor),
                  SizedBox(width: 10.w),
                  Text(
                    "Add New Mess",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: PrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          // List of available Messes
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: ctrl.messes.length,
              itemBuilder: (context, index) {
                final mess = ctrl.messes[index];
                return RadioListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: PrimaryColor,
                  title: Text(
                    mess.name ?? "Unnamed Mess",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  value: mess.id,
                  groupValue: tempSelectedId,
                  onChanged: (value) {
                    setState(() {
                      tempSelectedId = value;
                    });
                  },
                );
              },
            ),
          ),
          Divider(color: Colors.grey.withOpacity(0.3)),
          // Add Mess Button
          InkWell(
            onTap: () {
              Get.back();
              Get.bottomSheet(AddMessBottomSheet(), isScrollControlled: true);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline, color: PrimaryColor),
                  SizedBox(width: 10.w),
                  Text(
                    "Add New Mess",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: PrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),
          // Save Button
          SizedBox(
            width: double.infinity,
            height: 45.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: PrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              onPressed: () {
                if (tempSelectedId != null) {
                  ctrl.selectedMessId = tempSelectedId ?? "";
                  ctrl.refreshAllData();
                  ctrl.update();
                }
                Get.back(); // Close bottom sheet
              },
              child: Text(
                "Save",
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
