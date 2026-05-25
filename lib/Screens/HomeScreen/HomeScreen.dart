import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess/Screens/Customer/AddCustomerScreen.dart';
import 'package:mess/Screens/HomeScreen/HomeShimmerView.dart';
import 'package:mess/Screens/HomeScreen/HomeView.dart';
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/HomeScreen/Service/dashbaord_controller.dart';
import 'package:mess/Screens/HomeScreen/Views/StatItem.dart';
import 'package:mess/Screens/PartnerScreen/Views/AddPartnerScreen.dart';
import 'package:mess/Screens/SubscriptionScreen/SubscriptionScreen.dart';
import 'package:mess/Screens/Utils/Colors.dart';

class Homescreen extends StatelessWidget {
  Homescreen({super.key});
  HomeScreenController ctrl = Get.put(HomeScreenController());
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
                        ctrl.authController.currentUser!.name[0],
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
                          ctrl.authController.currentUser!.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        if (ctrl.messes.length == 1)
                          Text(
                            ctrl.messes.first.name ?? "No Mess",
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        else if (ctrl.messes.length > 1)
                          DropdownButton<String>(
                            value: ctrl.authController.selectedMessId,
                            items:
                                ctrl.messes
                                    .map(
                                      (value) => DropdownMenuItem(
                                        child: Text(""),
                                        value: value.id,
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) => {},
                          ),
                      ],
                    ),
                    Spacer(),
                    Icon(CupertinoIcons.bell),
                  ],
                ),
                backgroundColor: Colors.white,
              ),
              body: SafeArea(
                child: GetBuilder<HomeScreenController>(
                  builder: (__) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          Container(
                            height: 140.h,
                            // width: 350.w,
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
                                        color: Colors.white.withValues(
                                          alpha: .9,
                                        ),
                                      ),
                                    ),
                                    RotatedBox(
                                      quarterTurns: 3,
                                      child: Icon(
                                        CupertinoIcons.back,
                                        color: Colors.white.withValues(
                                          alpha: .8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.h),
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
                                    iconColor: Color(0xFF4CB051), // Dark Green
                                    iconBgColor: Color(
                                      0xFFE4F3E8,
                                    ), // Light Green
                                    label: 'Orders',
                                    value:
                                        '${ctrl.dashboardData!.totalOrders ?? 0}',
                                  ),
                                ),
                                const DividerWidget(),
                                Expanded(
                                  child: StatItem(
                                    icon: Icons.group_outlined,
                                    iconColor: Color(0xFF10938F), // Dark Teal
                                    iconBgColor: Color(
                                      0xFFE2F3F3,
                                    ), // Light Teal
                                    label: 'Customers',
                                    value:
                                        '${ctrl.dashboardData!.totalCustomers ?? 0}',
                                  ),
                                ),
                                const DividerWidget(),
                                Expanded(
                                  child: StatItem(
                                    icon: Icons.handshake_outlined,
                                    iconColor: Color(0xFFF67C31), // Dark Orange
                                    iconBgColor: Color(
                                      0xFFFEF3ED,
                                    ), // Light Orange
                                    label: 'Partners',
                                    value:
                                        '${ctrl.dashboardData!.totalPartners ?? 0}',
                                  ),
                                ),
                                const DividerWidget(),
                                Expanded(
                                  child: StatItem(
                                    icon: Icons.account_balance_wallet_outlined,
                                    iconColor: Color(0xFF8A59F8), // Dark Purple
                                    iconBgColor: Color(
                                      0xFFEAE5FA,
                                    ), // Light Purple
                                    label: 'Avg/Customer',
                                    value:
                                        '₹${ctrl.dashboardData!.avgPerCustomer ?? 0}',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12.sp),
                          Text(
                            '  Revenue Summary',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF111827), // Very Dark Gray
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: RevenueCard(
                                  title: 'Total Revenue',
                                  amount: '₹0.00',
                                  period: 'This Month',
                                  icon: Icons.trending_up,
                                  themeColor: const Color(
                                    0xFF2ECA50,
                                  ), // Vibrant Green
                                  iconBgColor: const Color(
                                    0xFFE8F8EE,
                                  ), // Faint Green for Icon
                                  cardBgColor: const Color(
                                    0xFFF9FCF9,
                                  ), // Faint Green for Card
                                ),
                              ),

                              Expanded(
                                child: RevenueCard(
                                  title: 'Pending Revenue',
                                  amount: '₹0.00',
                                  period: 'This Week',
                                  icon: Icons.access_time,
                                  themeColor: const Color(
                                    0xFFF16E22,
                                  ), // Vibrant Orange
                                  iconBgColor: const Color(
                                    0xFFFEF2E9,
                                  ), // Faint Orange for Icon
                                  cardBgColor: const Color(
                                    0xFFFFF9F5,
                                  ), // Faint Orange for Card
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            '  Quick Actions',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF111827), // Dark Gray
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Padding(
                            padding: EdgeInsetsGeometry.symmetric(
                              horizontal: 10.w,
                            ),
                            child: Row(
                              spacing: 8.w,
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
                                      iconColor: const Color(
                                        0xFF269185,
                                      ), // Teal
                                      iconBgColor: const Color(
                                        0xFFE8F6F4,
                                      ), // Faint Teal
                                    ),
                                  ),
                                ),
                                // Expanded(
                                //   child: QuickActionCard(
                                //     label: 'New Delivery',
                                //     icon: Icons.local_shipping_outlined,
                                //     iconColor: const Color(0xFF2E61D8), // Blue
                                //     iconBgColor: const Color(0xFFE9F0FD), // Faint Blue
                                //   ),
                                // ),
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
                                      iconColor: const Color(
                                        0xFF7D39D3,
                                      ), // Purple
                                      iconBgColor: const Color(
                                        0xFFEFE8FB,
                                      ), // Faint Purple
                                    ),
                                  ),
                                ),
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
                                      iconColor: const Color(
                                        0xFFDC9E2C,
                                      ), // Yellow/Orange
                                      iconBgColor: const Color(
                                        0xFFFEF5E5,
                                      ), // Faint Yellow/Orange
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
