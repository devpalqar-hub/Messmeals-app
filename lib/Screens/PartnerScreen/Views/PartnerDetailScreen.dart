import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/PartnerScreen/Model/PartnerModel.dart';
import 'package:mess/Screens/PartnerScreen/Service/PartnerController.dart';
import 'package:mess/Screens/PartnerScreen/Views/AddPartnerScreen.dart';
import 'package:mess/Screens/PartnerScreen/Views/StatusCard.dart';

class PartnerDetailsScreen extends StatefulWidget {
  final String partnerId;
  const PartnerDetailsScreen({super.key, required this.partnerId});

  @override
  State<PartnerDetailsScreen> createState() => _PartnerDetailsScreenState();
}

class _PartnerDetailsScreenState extends State<PartnerDetailsScreen> {
  final PartnerController controller = Get.find<PartnerController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPartnerById(widget.partnerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F9FB),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final partner = controller.selectedPartner.value;
          if (partner == null) {
            return const Center(child: Text("Partner details not found"));
          }

          final profile = partner.deliveryPartnerProfile;
          final stats = partner.stats;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ---------- HEADER ----------
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, size: 22.sp),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      "Partner Details",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Inter",
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),

                    /// EDIT BUTTON
                    GestureDetector(
                      onTap: () async {
                        await controller.fetchPartnerById(widget.partnerId);
                        final selected = controller.selectedPartner.value;

                        if (selected == null) {
                          Get.snackbar("Error", "Failed to load partner details");
                          return;
                        }

                        final result = await Get.to(() => AddPartnerScreen(
                              isEdit: true,
                              partner: selected,
                            ));

                        if (result == true) {
                          await controller.fetchPartners();
                          Get.back();
                          Get.snackbar("Success", "Partner updated successfully",
                              snackPosition: SnackPosition.BOTTOM);
                        }
                      },
                      child: _actionButton(Icons.edit_outlined, "Edit"),
                    ),

                    SizedBox(width: 8.w),

                    /// DELETE BUTTON
                    GestureDetector(
                      onTap: () => _confirmDelete(context, partner.id),
                      child: _actionButton(Icons.delete_outline, "Delete"),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                /// ---------- PROFILE CARD ----------
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28.r,
                        backgroundColor: Colors.grey.shade300,
                        child: Text(
                          partner.name.isNotEmpty
                              ? partner.name.substring(0, 2).toUpperCase()
                              : "NA",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Inter",
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 30.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              partner.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18.sp,
                                fontFamily: "Inter",
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            _infoRow(Icons.phone, partner.phone),
                            SizedBox(height: 4.h),
                            _infoRow(Icons.email_outlined, partner.email),
                            SizedBox(height: 4.h),
                            _infoRow(
                              Icons.location_on_outlined,
                              profile?.address ?? "No address available",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                /// ---------- STATS GRID ----------
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 1.55,
                  children: [
                    StatsCard(
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.green,
                      label: "COMPLETED",
                      value: "${stats?.completedDeliveries ?? 0}",
                    ),
                    StatsCard(
                      icon: Icons.inventory_2_outlined,
                      iconColor: Colors.blue,
                      label: "TOTAL DELIVERIES",
                      value: "${stats?.totalDeliveries ?? 0}",
                    ),
                    StatsCard(
                      icon: Icons.trending_up,
                      iconColor: Colors.purple,
                      label: "EARNINGS",
                      value: "₹${stats?.totalEarnings ?? 0}",
                    ),
                    StatsCard(
                      icon: Icons.calendar_today_outlined,
                      iconColor: Colors.orange,
                      label: "PENDING",
                      value: "${stats?.pendingDeliveries ?? 0}",
                    ),
                  ],
                ),

                SizedBox(height: 16.h),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// ---------- INFO ROW ----------
  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: const Color(0xff717182),
              fontSize: 14.sp,
              fontFamily: "Inter",
            ),
          ),
        ),
      ],
    );
  }

  /// ---------- ACTION BUTTON ----------
  Widget _actionButton(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade200),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: Colors.black87),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              fontFamily: "Inter",
            ),
          ),
        ],
      ),
    );
  }

  /// ---------- DELETE CONFIRMATION ----------
  void _confirmDelete(BuildContext context, String partnerId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Text(
          "Delete Partner",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        content: Text(
          "Are you sure you want to delete this partner?",
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Cancel",
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await controller.fetchPartners();
              Get.back();
              Get.snackbar("Success", "Partner deleted successfully",
                  snackPosition: SnackPosition.BOTTOM);
            },
            child: Text(
              "Delete",
              style: TextStyle(color: Colors.red, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}
