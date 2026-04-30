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
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
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
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Inter",
                        color: const Color(0xff0A0A0A),
                      ),
                    ),
                    if (isActive)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle,
                                size: 14.sp, color: Colors.white),
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
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                     
                      await controller.fetchPartnerById(id);

                     
                      final partner = controller.selectedPartner;
                      if (partner == null) {
                        Get.snackbar("Error", "Failed to load partner details");
                        return;
                      }

                      final result = await Get.to(() => AddPartnerScreen(
                            isEdit: true,
                            partner: partner,
                          ));

                      if (result == true) {
                        await controller.fetchPartners();
                      }
                    },
                    icon: Icon(Icons.edit_outlined, size: 22.sp),
                  ),
                  IconButton(
                    onPressed: () => _confirmDelete(context, id, controller),
                    icon: Icon(Icons.delete_outline, size: 20.sp),
                  ),
                  IconButton(
                    onPressed: () {
                      Get.to(() => PartnerDetailsScreen(partnerId: id));
                    },
                    icon: Icon(Icons.chevron_right, size: 22.sp),
                  ),
                ],
              ),
            ],
          ),
          Text(
            phone,
            style: TextStyle(
              fontSize: 15.sp,
              fontFamily: "Inter",
              fontWeight: FontWeight.w400,
              color: const Color(0xff717182),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            email,
            style: TextStyle(
              fontSize: 15.sp,
              fontFamily: "Inter",
              fontWeight: FontWeight.w400,
              color: const Color(0xff717182),
            ),
          ),
          SizedBox(height: 12.h),
          Divider(color: Colors.grey[300]),
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
                        color: const Color(0xff717182),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "$totalOrders",
                      style: TextStyle(
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
                        color: const Color(0xff717182),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      location,
                      style: TextStyle(
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
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// ICON
              Icon(
                Icons.warning_amber_rounded,
                color: const Color(0xffF28B82),
                size: 45.sp,
              ),

              SizedBox(height: 12.h),

              /// TITLE
              Text(
                "Delete Partner?",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                ),
              ),

              SizedBox(height: 8.h),

              /// MESSAGE
              Text(
                "Are you sure you want to delete this partner?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14.sp,
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
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 10.w),

                  /// DELETE
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx); // close dialog first
                        await controller.deletePartner(partnerId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        "Delete",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
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