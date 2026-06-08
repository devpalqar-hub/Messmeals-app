import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess/Screens/PartnerScreen/Service/PartnerController.dart';
import 'package:mess/Screens/PartnerScreen/Views/AddPartnerScreen.dart';
import 'package:mess/Screens/Utils/AppColors.dart';
import 'package:mess/Screens/Utils/AppToast.dart';

class PartnerDetailsScreen extends StatelessWidget {
  final String partnerId;
  const PartnerDetailsScreen({super.key, required this.partnerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFF7F9FB), // Clean off-white background
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GetBuilder<PartnerController>(
          initState: (_) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.find<PartnerController>().fetchPartnerById(partnerId);
            });
          },
          builder: (controller) {
            if (controller.isLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
              );
            }

            final partner = controller.selectedPartner;
            if (partner == null) {
              return Center(
                child: Text(
                  "Partner details not found",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              );
            }

            final profile = partner.deliveryPartnerProfile;
            final stats = partner.stats;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER & ACTIONS
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back_ios_new_outlined,
                          size: 18.sp,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        "Partner Details",
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      // const Spacer(),

                      // /// EDIT BUTTON
                      // GestureDetector(
                      //   onTap: () async {
                      //     await controller.fetchPartnerById(partnerId);
                      //     final selected = controller.selectedPartner;
                      //     if (selected == null) {
                      //       Get.snackbar(
                      //         "Error",
                      //         "Failed to load partner details",
                      //       );
                      //       return;
                      //     }
                      //     final result = await Get.to(
                      //       () => AddPartnerScreen(
                      //         isEdit: true,
                      //         partner: selected,
                      //       ),
                      //     );
                      //     if (result == true) {
                      //       await controller.fetchPartners();
                      //       Get.back();
                      //       Get.snackbar(
                      //         "Success",
                      //         "Partner updated successfully",
                      //         snackPosition: SnackPosition.BOTTOM,
                      //         backgroundColor: Colors.green.shade50,
                      //         colorText: Colors.green.shade800,
                      //       );
                      //     }
                      //   },
                      //   child: _actionIcon(
                      //     Icons.edit_outlined,
                      //     AppColors.primary,
                      //     AppColors.primary.withOpacity(0.1),
                      //   ),
                      // ),
                      // SizedBox(width: 10.w),

                      // /// DELETE BUTTON
                      // GestureDetector(
                      //   onTap:
                      //       () =>
                      //           _confirmDelete(context, partner.id, controller),
                      //   child: _actionIcon(
                      //     Icons.delete_outline,
                      //     Colors.red.shade600,
                      //     Colors.red.shade50,
                      //   ),
                      // ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  /// PARTNER INFO CARD
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// AVATAR
                        Container(
                          height: 56.w,
                          width: 56.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            partner.name.isNotEmpty
                                ? partner.name.substring(0, 2).toUpperCase()
                                : "NA",
                            style: GoogleFonts.poppins(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),

                        /// DETAILS
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                partner.name,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                              SizedBox(height: 6.h),
                              _infoRow(Icons.phone_outlined, partner.phone),
                              SizedBox(height: 4.h),
                              // _infoRow(Icons.email_outlined, partner.email),
                              // SizedBox(height: 4.h),
                              // _infoRow(
                              //   Icons.location_on_outlined,
                              //   profile?.address ?? "No address provided",
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),
                  Text(
                    "Performance Stats",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  /// STATS GRID
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 1.4, // Adjusted for compact look
                    children: [
                      _buildStatCard(
                        icon: Icons.check_circle_outline,
                        iconColor: const Color(0xFF4CB051), // Green
                        iconBgColor: const Color(0xFFE4F3E8),
                        label: "Completed",
                        value: "${stats?.completedDeliveries ?? 0}",
                      ),
                      _buildStatCard(
                        icon: Icons.inventory_2_outlined,
                        iconColor: const Color(0xFF2E61D8), // Blue
                        iconBgColor: const Color(0xFFE9F0FD),
                        label: "Total Deliveries",
                        value: "${stats?.totalDeliveries ?? 0}",
                      ),
                      _buildStatCard(
                        icon: Icons.account_balance_wallet_outlined,
                        iconColor: const Color(0xFF8A59F8), // Purple
                        iconBgColor: const Color(0xFFEAE5FA),
                        label: "Earnings",
                        value: "₹${stats?.totalEarnings ?? 0}",
                      ),
                      _buildStatCard(
                        icon: Icons.access_time_outlined,
                        iconColor: const Color(0xFFF16E22), // Orange
                        iconBgColor: const Color(0xFFFEF2E9),
                        label: "Pending",
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
  Widget _actionIcon(IconData icon, Color color, Color bgColor) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(icon, size: 18.sp, color: color),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14.sp, color: Colors.grey.shade500),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(icon, color: iconColor, size: 18.sp),
          ),
          const Spacer(),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
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
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red.shade400,
                  size: 40.sp,
                ),
                SizedBox(height: 12.h),
                Text(
                  "Delete Partner?",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Are you sure you want to delete this partner? This action cannot be undone.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
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
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await controller.deletePartner(partnerId);
                          await controller.fetchPartners();
                          Get.back(); // Closes details screen
                          AppToast.success("Partner deleted successfully");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade500,
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
