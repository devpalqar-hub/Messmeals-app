import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/PartnerScreen/Model/PartnerModel.dart';
import 'package:mess/Screens/PartnerScreen/Service/PartnerController.dart';
import 'package:mess/Screens/PartnerScreen/Views/AddPartnerScreen.dart';
import 'package:mess/Screens/PartnerScreen/Views/StatusCard.dart';

class PartnerDetailsScreen extends StatelessWidget {
  final String partnerId;
  const PartnerDetailsScreen({super.key, required this.partnerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F9FB),
      body: SafeArea(
   
        child: GetBuilder<PartnerController>(
          // GetBuilder allows us to handle initState directly
          initState: (_) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.find<PartnerController>().fetchPartnerById(partnerId);
            });
          },
          builder: (controller) {
            // Note: Removed .value assuming you are no longer using .obs in the controller
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final partner = controller.selectedPartner;
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
                          await controller.fetchPartnerById(partnerId);
                          final selected = controller.selectedPartner;

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
                            Get.snackbar(
                              "Success",
                              "Partner updated successfully",
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                        child: _actionButton(Icons.edit_outlined, "Edit"),
                      ),

                      SizedBox(width: 8.w),

                      /// DELETE BUTTON
                      GestureDetector(
                        onTap: () => _confirmDelete(context, partner.id, controller),
                        child: _actionButton(Icons.delete_outline, "Delete"),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.h),

                  /// PARTNER INFO CARD
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

                  /// STATS GRID
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
          },
        ),
      ),
    );
  }

  /// HELPER WIDGETS
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

  void _confirmDelete(
      BuildContext context, String partnerId, PartnerController controller) {
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
              Get.back(); // Closes the details screen
              Get.snackbar(
                "Success",
                "Partner deleted successfully",
                snackPosition: SnackPosition.BOTTOM,
              );
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