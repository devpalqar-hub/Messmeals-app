// DELIVERY PARTNER MODULE — DISABLED (admin-only build for now)
// Entire file commented out below; not wired into the app.
/*
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess/Screens/DeliveryPartner/Deliveries/Models/PartnerDeliveryModel.dart';
import 'package:mess/Screens/DeliveryPartner/Deliveries/Service/PartnerDeliveryController.dart';
import 'package:mess/Screens/DeliveryPartner/Deliveries/Views/DeliveryDetailScreen.dart';
import 'package:mess/Screens/DeliveryPartner/Earnings/Service/MockEarningsController.dart';
import 'package:mess/Screens/DeliveryPartner/Profile/Service/DeliveryProfileController.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class DeliveryHomeScreen extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const DeliveryHomeScreen({super.key, required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final deliveryCtrl = Get.put(PartnerDeliveryController());
    final profileCtrl = Get.put(DeliveryProfileController());
    final earningsCtrl = Get.put(MockEarningsController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      deliveryCtrl.fetchTodaySummary();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GetBuilder<PartnerDeliveryController>(
          builder: (ctrl) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ---------- GREETING ----------
                  Row(
                    children: [
                      Container(
                        height: 44.w,
                        width: 44.w,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 22.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: GetBuilder<DeliveryProfileController>(
                          builder: (pCtrl) {
                            final name =
                                pCtrl.profile?.name.isNotEmpty == true
                                    ? pCtrl.profile!.name
                                    : 'there';
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Good ${_greetingPart()},",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.grey.shade600,
                        size: 24.sp,
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "Let's deliver happiness today! 🎉",
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),

                  SizedBox(height: 18.h),

                  /// ---------- TODAY'S DELIVERIES ----------
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's Deliveries",
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 14.h),
                        Row(
                          children: [
                            _homeStat("${ctrl.assignedToday}", "Assigned"),
                            _homeStat("${ctrl.completedToday}", "Completed"),
                            _homeStat("${ctrl.pendingToday}", "Pending"),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  /// ---------- TODAY'S EARNINGS ----------
                  GetBuilder<MockEarningsController>(
                    builder: (eCtrl) {
                      return InkWell(
                        onTap: () => onNavigateToTab(3),
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: AppColors.primary,
                                  size: 18.sp,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Today's Earnings",
                                      style: GoogleFonts.poppins(
                                        fontSize: 11.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      "₹${eCtrl.todayEarnings.toStringAsFixed(0)}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF111827),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 20.h),

                  /// ---------- RECENT DELIVERIES ----------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Recent Deliveries",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => onNavigateToTab(1),
                        child: Text(
                          "View All",
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  if (ctrl.isLoadingToday)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 30.h),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  else if (ctrl.recentDeliveries.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Text(
                        "No deliveries yet today",
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    )
                  else
                    ...ctrl.recentDeliveries.map(
                      (d) => _RecentDeliveryTile(
                        delivery: d,
                        onTap: () {
                          Get.to(() => DeliveryDetailScreen(deliveryId: d.id));
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _greetingPart() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Morning";
    if (hour < 17) return "Afternoon";
    return "Evening";
  }

  Widget _homeStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentDeliveryTile extends StatelessWidget {
  final PartnerDeliveryModel delivery;
  final VoidCallback onTap;

  const _RecentDeliveryTile({required this.delivery, required this.onTap});

  Color get _statusColor {
    switch (delivery.status) {
      case 'COMPLETED':
        return AppColors.success;
      case 'CANCELLED':
        return Colors.red.shade400;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              height: 36.w,
              width: 36.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                delivery.customerName.isNotEmpty
                    ? delivery.customerName[0].toUpperCase()
                    : '?',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    delivery.customerName,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    delivery.mealSummary.isNotEmpty
                        ? "${delivery.mealSummary} • ${delivery.planName}"
                        : delivery.planName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                delivery.status[0] + delivery.status.substring(1).toLowerCase(),
                style: GoogleFonts.poppins(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                  color: _statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

*/
