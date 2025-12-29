import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/PartnerScreen/Service/PartnerController.dart';
import 'package:mess/Screens/PartnerScreen/Views/AddPartnerScreen.dart';
import 'package:mess/Screens/PartnerScreen/Views/PartnerDetailScreen.dart';

class PartnerCard extends StatelessWidget {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String location;
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding:  EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Top Row: Name + Active badge + icons ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text(
                      name,
                      style:  TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Inter",
                        color: Color(0xff0A0A0A),
                      ),
                    ),
                    if (isActive)
                      Container(
                        padding:  EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child:  Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, size: 14.sp, color: Colors.white),
                            SizedBox(width: 4.w),
                            Text(
                              "active",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Inter",
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // ---------- Action buttons ----------
              Row(
                children: [
                  // ✅ Edit Button
                  IconButton(
                    onPressed: () async {
                      await controller.fetchPartnerById(id);

                      final partner = controller.selectedPartner.value;
                      if (partner == null) {
                        Get.snackbar("Error", "Failed to load partner details");
                        return;
                      }

                      // Navigate to AddPartnerScreen for edit
                      final result = await Get.to(() => AddPartnerScreen(
                            isEdit: true,
                            partner: partner,
                          ));

                      if (result == true) {
                        // Refresh and show snackbar when returned
                        await controller.fetchPartners();
                        Get.snackbar("Success", "Partner updated successfully",
                            snackPosition: SnackPosition.BOTTOM);
                      }
                    },
                    icon:  Icon(Icons.edit_outlined, size: 22.sp),
                  ),

                  // ✅ Delete Button
                  IconButton(
                    onPressed: () => _confirmDelete(context, id, controller),
                    icon:  Icon(Icons.delete_outline, size: 20.sp),
                  ),

                  // ✅ View Details Button
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PartnerDetailsScreen(partnerId: id),
                        ),
                      );
                    },
                    icon:  Icon(Icons.chevron_right, size: 22.sp),
                  ),
                ],
              ),
            ],
          ),

          // --- Contact Info ---
          Text(
            phone,
            style:  TextStyle(
              fontSize: 15.sp,
              fontFamily: "Inter",
              fontWeight: FontWeight.w400,
              color: Color(0xff717182),
            ),
          ),
           SizedBox(height: 2.h),
          Text(
            email,
            style: TextStyle(
              fontSize: 15.sp,
              fontFamily: "Inter",
              fontWeight: FontWeight.w400,
              color: Color(0xff717182),
            ),
          ),

           SizedBox(height: 12.h),
          Divider(color: Colors.grey[300]),

          // --- Bottom Row: Orders + Location ---
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      "TOTAL ORDERS",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w500,
                        color: Color(0xff717182),
                      ),
                    ),
                     SizedBox(height: 4.h),
                    Text(
                      "$totalOrders",
                      style:  TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Inter",
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "LOCATION",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w500,
                        color: Color(0xff717182),
                      ),
                    ),
                     SizedBox(height: 4.h),
                    Text(
                      location,
                      style:  TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontFamily: "Inter",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ✅ Delete Confirmation Dialog
  void _confirmDelete(BuildContext context, String partnerId, PartnerController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Partner"),
        content: const Text("Are you sure you want to delete this partner?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await controller.deletePartner(partnerId);
              await controller.fetchPartners();

              Get.snackbar("Success", "Partner deleted successfully",
                  snackPosition: SnackPosition.BOTTOM);

              // ✅ Go back to previous screen (list with bottom bar)
              if (Navigator.canPop(context)) {
                Navigator.pop(context, true); // return true to refresh
              }
            },
            child:  Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
