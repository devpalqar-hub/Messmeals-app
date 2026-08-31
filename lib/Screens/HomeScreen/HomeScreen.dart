import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mess/Screens/Customer/AddCustomerScreen.dart';
import 'package:mess/Screens/ExpenseScreen/ExpenseScreen.dart';
import 'package:mess/Screens/ExpenseScreen/Service/ExpenseController.dart';
import 'package:mess/Screens/HomeScreen/HomeShimmerView.dart';
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/HomeScreen/Views/ProfileBottomSheet.dart';
// import 'package:mess/Screens/HomeScreen/Service/dashbaord_controller.dart'; // Adjust if needed
import 'package:mess/Screens/HomeScreen/Views/SelectMessBottomSheet.dart';
import 'package:mess/Screens/HomeScreen/Views/StatItem.dart';
import 'package:mess/Screens/MealBreakDownScreen/MealBreakDownScreen.dart';
import 'package:mess/Screens/PartnerScreen/Views/AddPartnerScreen.dart';
import 'package:mess/Screens/SettingsScreen/MessProfileSettingsScreen.dart';
import 'package:mess/Screens/SubscriptionScreen/SubscriptionScreen.dart';
import 'package:mess/Screens/Utils/AppColors.dart';
import 'package:mess/Screens/Utils/routes.dart';

class Homescreen extends StatelessWidget {
  final Function(int) onNavigateToTab;
  Homescreen({super.key, required this.onNavigateToTab});

  final HomeScreenController ctrl = Get.put(HomeScreenController());
  final ExpenseController expenseController = Get.put(ExpenseController());

  // BUG #2427 — Logout function: clears prefs and navigates to login
  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            title: const Text("Logout"),
            content: const Text("Are you sure you want to logout?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeScreenController>(
      builder: (__) {
        return (ctrl.dashboardData == null)
            ? HomeShimmerScreen()
            : Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                titleSpacing: 16.w,
                title: Row(
                  children: [
                    Container(
                      height: 38.w,
                      width: 38.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: AppColors.primaryGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        ctrl.user!.name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ctrl.user!.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (ctrl.selectedMessId != null)
                          InkWell(
                            onTap: () {
                              Get.bottomSheet(
                                SelectMessBottomsheet(),
                                isScrollControlled: true,
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  ctrl.messes
                                          .where(
                                            (it) =>
                                                ctrl.selectedMessId == it.id,
                                          )
                                          .first
                                          .name ??
                                      "No Mess",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                RotatedBox(
                                  quarterTurns: 3,
                                  child: Icon(
                                    Icons.arrow_back_ios_new_outlined,
                                    size: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        Get.bottomSheet(ProfileBottomSheet());
                      },
                      child: Icon(
                        CupertinoIcons.person_circle,
                        color: Colors.black87,
                      ),
                    ),

                    // Settings icon — opens the Mess Profile Settings screen
                    IconButton(
                      onPressed: () {
                        Get.to(
                          () => const MessProfileSettingsScreen(),
                          transition: Transition.rightToLeft,
                        );
                      },
                      icon: const Icon(Icons.settings_outlined),
                      color: const Color(0xFF111827),
                    ),
                  ],
                ),
                backgroundColor: Colors.white,
                elevation: 0,
              ),
              body: SafeArea(
                child: GetBuilder<HomeScreenController>(
                  builder: (__) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h),

                          // TOP REVENUE CARD
                          Container(
                            width: double.infinity,
                            height: 122.h,
                            margin: EdgeInsets.symmetric(horizontal: 10.w),
                            padding: EdgeInsets.symmetric(
                              horizontal: 22.w,
                              vertical: 18.h,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14.r),
                              gradient: LinearGradient(
                                colors: AppColors.primaryGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.28),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: -6.w,
                                  top: -6.h,
                                  child: Icon(
                                    Icons.account_balance_wallet_rounded,
                                    size: 72.sp,
                                    color: Colors.white.withOpacity(0.14),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Total Revenue",
                                      style: GoogleFonts.poppins(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    // BUG #2435 — format to avoid long decimal overflow
                                    Text(
                                      "₹ ${_formatAmount(ctrl.dashboardData!.totalRevenue ?? 0)}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 26.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Text(
                                      "Overall earnings",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white.withOpacity(0.85),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // REVENUE SUMMARY — grouped with the hero card since both are financial figures
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Text(
                              'Revenue Summary',
                              style: GoogleFonts.poppins(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF111827),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              Expanded(
                                child: RevenueCard(
                                  title: 'Total Revenue',
                                  // BUG #2435 — format revenue amounts
                                  amount:
                                      '₹${_formatAmount(ctrl.dashboardData!.totalRevenue!)}',
                                  period: 'This Month',
                                  icon: Icons.trending_up,
                                  themeColor: AppColors.primaryDark,
                                  iconBgColor: AppColors.primary.withOpacity(0.12),
                                  cardBgColor: const Color(0xFFF9FCF9),
                                ),
                              ),
                              Expanded(
                                child: RevenueCard(
                                  title: 'Pending Revenue',
                                  amount:
                                      '₹${_formatAmount(ctrl.dashboardData!.pendingRevenue!)}',
                                  period: 'Over All',
                                  icon: Icons.access_time,
                                  themeColor: const Color(0xFFF16E22),
                                  iconBgColor: const Color(0xFFFEF2E9),
                                  cardBgColor: const Color(0xFFFFF9F5),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 22.h),

                          // OVERVIEW — KPI GRID (BUG #2435: format Avg/Customer to avoid overflow)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Text(
                              'Overview',
                              style: GoogleFonts.poppins(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF111827),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _kpiCard(
                                    onTap: () => onNavigateToTab(3),
                                    icon: Icons.shopping_bag_outlined,
                                    iconColor: const Color(0xFF4CB051),
                                    iconBgColor: const Color(0xFFE4F3E8),
                                    label: 'Orders',
                                    value:
                                        '${ctrl.dashboardData!.totalOrders ?? 0}',
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: _kpiCard(
                                    onTap: () => onNavigateToTab(1),
                                    icon: Icons.group_outlined,
                                    iconColor: const Color(0xFF10938F),
                                    iconBgColor: const Color(0xFFE2F3F3),
                                    label: 'Customers',
                                    value:
                                        '${ctrl.dashboardData!.totalCustomers ?? 0}',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _kpiCard(
                                    onTap: () => onNavigateToTab(2),
                                    icon: Icons.handshake_outlined,
                                    iconColor: const Color(0xFFF67C31),
                                    iconBgColor: const Color(0xFFFEF3ED),
                                    label: 'Partners',
                                    value:
                                        '${ctrl.dashboardData!.totalPartners ?? 0}',
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: GetBuilder<ExpenseController>(
                                    builder: (expenseCtrl) {
                                      return _kpiCard(
                                        onTap: () => Get.to(() => const ExpenseScreen()),
                                        icon: Icons.receipt_long_outlined,
                                        iconColor: const Color(0xFFC0392B),
                                        iconBgColor: const Color(0xFFFBEAE8),
                                        label: 'Expenses',
                                        value:
                                            '₹${_formatAmount(expenseCtrl.listSummary.total.amount)}',
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 22.h),
                          // QUICK ACTIONS
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Text(
                              'Quick Actions',
                              style: GoogleFonts.poppins(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF111827),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap:
                                        () => Get.to(
                                          () => AddCustomerScreen(),
                                          transition: Transition.rightToLeft,
                                        ),
                                    child: QuickActionCard(
                                      label: 'Add Customer',
                                      icon: Icons.person_add_alt_1_outlined,
                                      iconColor: AppColors.primaryDark,
                                      iconBgColor: AppColors.primary.withOpacity(0.12),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: InkWell(
                                    onTap:
                                        () => Get.to(
                                          () => AddPartnerScreen(),
                                          transition: Transition.rightToLeft,
                                        ),
                                    child: QuickActionCard(
                                      label: 'Add Partner',
                                      icon: Icons.group_outlined,
                                      iconColor: const Color(0xFF7D39D3),
                                      iconBgColor: const Color(0xFFEFE8FB),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: InkWell(
                                    onTap:
                                        () => Get.to(
                                          () => SubscriptionScreen(),
                                          transition: Transition.rightToLeft,
                                        ),
                                    child: QuickActionCard(
                                      label: 'Reports',
                                      icon: Icons.pie_chart_outline,
                                      iconColor: const Color(0xFFDC9E2C),
                                      iconBgColor: const Color(0xFFFEF5E5),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: InkWell(
                                    onTap:
                                        () => Get.to(
                                          () => const ExpenseScreen(),
                                          transition: Transition.rightToLeft,
                                        ),
                                    child: QuickActionCard(
                                      label: 'Expenses',
                                      icon: Icons.receipt_long_outlined,
                                      iconColor: const Color(0xFFC0392B),
                                      iconBgColor: const Color(0xFFFBEAE8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 14.h),
                          // FOOD PREP ANALYTICS BUTTON
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Get.to(
                                    () => MealsAnalyticsScreen(),
                                    transition: Transition.rightToLeft,
                                  );
                                },
                                borderRadius: BorderRadius.circular(10.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 14.h,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primaryDark,
                                        AppColors.primary,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10.w),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.restaurant_menu,
                                          color: Colors.white,
                                          size: 24.sp,
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Food Prep Analytics",
                                              style: GoogleFonts.poppins(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              "View daily variation counts & plans",
                                              style: GoogleFonts.poppins(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white.withOpacity(
                                                  0.9,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white,
                                        size: 16.sp,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 20.h),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
      },
    );
  }

  /// Compact KPI tile used in the Overview grid — icon left, value + label right.
  Widget _kpiCard({
    VoidCallback? onTap,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFF1F3F5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 40.w,
              width: 40.w,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: iconColor, size: 20.sp),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// BUG #2435 — formats numbers: removes trailing decimals, rounds to int
  String _formatAmount(dynamic value) {
    if (value == null) return '0';
    final num parsed =
        value is num ? value : num.tryParse(value.toString()) ?? 0;
    // If it's a whole number, show without decimals
    if (parsed == parsed.roundToDouble()) {
      return parsed.toInt().toString();
    }
    // Otherwise round to 2 decimal places max
    return parsed.toStringAsFixed(2);
  }
}
