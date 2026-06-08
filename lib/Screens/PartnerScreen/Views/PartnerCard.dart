import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess/Screens/PartnerScreen/Service/PartnerController.dart';
import 'package:mess/Screens/PartnerScreen/Views/AddPartnerScreen.dart';
import 'package:mess/Screens/PartnerScreen/Views/PartnerDetailScreen.dart';
import 'package:mess/Screens/Utils/AppToast.dart';

class PartnerCard extends StatelessWidget {
  final String id;
  final String name;
  final String phone; // Kept in constructor so parent doesn't break
  final String email; // Kept in constructor
  final String location; // Kept in constructor
  final int totalOrders;
  final bool isActive;

  const PartnerCard({
    super.key,
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.location,
    required this.totalOrders,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PartnerController>();

    return Container(
      // margin: EdgeInsets.symmetric(vertical: 4.h), // Tight vertical spacing
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 10.h,
      ), // Slim padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r), // Matched theme radius
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), // Subtle shadow
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// DETAILS COLUMN
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    if (isActive)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFE4F3E8,
                          ), // Light green matching Home screen
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          "Active",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF4CB051), // Dark green
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  "Total Orders: $totalOrders",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          /// ACTIONS
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  await controller.fetchPartnerById(id);
                  final partner = controller.selectedPartner;
                  if (partner == null) {
                    AppToast.error("Failed to load partner details");
                    return;
                  }
                  final result = await Get.to(
                    () => AddPartnerScreen(isEdit: true, partner: partner),
                  );
                  if (result == true) {
                    await controller.fetchPartners();
                  }
                },
                child: Padding(
                  padding: EdgeInsets.all(6.w),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 16.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _confirmDelete(context, id, controller),
                child: Padding(
                  padding: EdgeInsets.all(6.w),
                  child: Icon(
                    Icons.delete_outline,
                    size: 16.sp,
                    color: Colors.red.shade400,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(() => PartnerDetailsScreen(partnerId: id));
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 6.w, top: 6.w, bottom: 6.w),
                  child: Icon(
                    Icons.chevron_right,
                    size: 20.sp,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    String partnerId,
    PartnerController controller,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// ICON
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red.shade400,
                  size: 40.sp,
                ),
                SizedBox(height: 12.h),

                /// TITLE
                Text(
                  "Delete Partner?",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 8.h),

                /// MESSAGE
                Text(
                  "Are you sure you want to delete this partner?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 20.h),

                /// BUTTONS
                Row(
                  children: [
                    /// CANCEL
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),

                    /// DELETE
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await controller.deletePartner(partnerId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.red.shade500, // Explicitly red for delete
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                        child: Text(
                          "Delete",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
