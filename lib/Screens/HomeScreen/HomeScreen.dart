import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Ensure these imports match your actual project structure
import 'package:mess/Screens/Customer/AddCustomerScreen.dart';
import 'package:mess/Screens/HomeScreen/HomeShimmerView.dart';
// import 'package:mess/Screens/HomeScreen/HomeView.dart'; // Adjust if needed
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
// import 'package:mess/Screens/HomeScreen/Service/dashbaord_controller.dart'; // Adjust if needed
import 'package:mess/Screens/HomeScreen/Views/SelectMessBottomSheet.dart';
import 'package:mess/Screens/HomeScreen/Views/StatItem.dart';
import 'package:mess/Screens/MealBreakDownScreen/MealBreakDownScreen.dart';
import 'package:mess/Screens/PartnerScreen/Views/AddPartnerScreen.dart';
import 'package:mess/Screens/SubscriptionScreen/SubscriptionScreen.dart';
import 'package:mess/Screens/Utils/Colors.dart';

// ---> IMPORTANT: Add the correct import for your new screen here <---
// import 'package:mess/Screens/MealsAnalytics/MealsAnalyticsScreen.dart';

class Homescreen extends StatelessWidget {
  Homescreen({super.key});

  final HomeScreenController ctrl = Get.put(HomeScreenController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeScreenController>(
      builder: (__) {
        return (ctrl.dashboardData == null)
            ? HomeShimmerScreen()
            : Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: PrimaryColor,
                      child: Text(
                        ctrl.user!.name[0],
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
                                SizedBox(width: 10),
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
                    Icon(CupertinoIcons.bell),
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
                          SizedBox(height: 20),

                          // TOP REVENUE CARD
                          Container(
                            height: 140.h,
                            margin: EdgeInsets.symmetric(horizontal: 10.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              image: const DecorationImage(
                                image: AssetImage("assets/homeRevenueCard.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                            padding: EdgeInsets.only(left: 30.w, top: 20.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Total Revenue",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  "₹ ${ctrl.dashboardData!.totalRevenue ?? 0}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 26.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Row(
                                  children: [
                                    Text(
                                      "This month",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                    RotatedBox(
                                      quarterTurns: 3,
                                      child: Icon(
                                        CupertinoIcons.back,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),

                          // 4-STAT ROW
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10.w),
                            margin: EdgeInsets.symmetric(horizontal: 10.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: StatItem(
                                    icon: Icons.shopping_bag_outlined,
                                    iconColor: Color(0xFF4CB051),
                                    iconBgColor: Color(0xFFE4F3E8),
                                    label: 'Orders',
                                    value:
                                        '${ctrl.dashboardData!.totalOrders ?? 0}',
                                  ),
                                ),
                                const DividerWidget(),
                                Expanded(
                                  child: StatItem(
                                    icon: Icons.group_outlined,
                                    iconColor: Color(0xFF10938F),
                                    iconBgColor: Color(0xFFE2F3F3),
                                    label: 'Customers',
                                    value:
                                        '${ctrl.dashboardData!.totalCustomers ?? 0}',
                                  ),
                                ),
                                const DividerWidget(),
                                Expanded(
                                  child: StatItem(
                                    icon: Icons.handshake_outlined,
                                    iconColor: Color(0xFFF67C31),
                                    iconBgColor: Color(0xFFFEF3ED),
                                    label: 'Partners',
                                    value:
                                        '${ctrl.dashboardData!.totalPartners ?? 0}',
                                  ),
                                ),
                                const DividerWidget(),
                                Expanded(
                                  child: StatItem(
                                    icon: Icons.account_balance_wallet_outlined,
                                    iconColor: Color(0xFF8A59F8),
                                    iconBgColor: Color(0xFFEAE5FA),
                                    label: 'Avg/Customer',
                                    value:
                                        '₹${ctrl.dashboardData!.avgPerCustomer ?? 0}',
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.h),

                          // ==========================================
                          // MAIN BUTTON: FOOD PREPARATION ANALYTICS
                          // ==========================================
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  // Ensure MealsAnalyticsScreen is properly imported
                                  Get.to(
                                    () => MealsAnalyticsScreen(),
                                    transition: Transition.rightToLeft,
                                  );
                                },
                                borderRadius: BorderRadius.circular(10.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 16.h,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF10938F),
                                        Color(0xFF0D7A76),
                                      ], // Teal Gradient
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF10938F,
                                        ).withOpacity(0.3),
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

                          // ==========================================
                          SizedBox(height: 24.h),

                          // REVENUE SUMMARY
                          Text(
                            '  Revenue Summary',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: RevenueCard(
                                  title: 'Total Revenue',
                                  amount:
                                      '₹${ctrl.dashboardData!.totalRevenue!}',
                                  period: 'This Month',
                                  icon: Icons.trending_up,
                                  themeColor: const Color(0xFF2ECA50),
                                  iconBgColor: const Color(0xFFE8F8EE),
                                  cardBgColor: const Color(0xFFF9FCF9),
                                ),
                              ),
                              Expanded(
                                child: RevenueCard(
                                  title: 'Pending Revenue',
                                  amount:
                                      '₹${ctrl.dashboardData!.pendingRevenue!}',
                                  period: 'This Week',
                                  icon: Icons.access_time,
                                  themeColor: const Color(0xFFF16E22),
                                  iconBgColor: const Color(0xFFFEF2E9),
                                  cardBgColor: const Color(0xFFFFF9F5),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),

                          // QUICK ACTIONS
                          Text(
                            '  Quick Actions',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(
                                        () => AddCustomerScreen(),
                                        transition: Transition.rightToLeft,
                                      );
                                    },
                                    child: QuickActionCard(
                                      label: 'Add Customer',
                                      icon: Icons.person_add_alt_1_outlined,
                                      iconColor: const Color(0xFF269185),
                                      iconBgColor: const Color(0xFFE8F6F4),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(
                                        () => AddPartnerScreen(),
                                        transition: Transition.rightToLeft,
                                      );
                                    },
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
                                    onTap: () {
                                      Get.to(
                                        () => SubscriptionScreen(),
                                        transition: Transition.rightToLeft,
                                      );
                                    },
                                    child: QuickActionCard(
                                      label: 'Reports',
                                      icon: Icons.pie_chart_outline,
                                      iconColor: const Color(0xFFDC9E2C),
                                      iconBgColor: const Color(0xFFFEF5E5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 30.h),
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
}

// NOTE: Ensure your existing DividerWidget, RevenueCard, and QuickActionCard 
// are correctly referenced or exist in the same file/imports.