import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/HomeScreen/Views/AnalyticsCard.dart';
import 'package:mess/Screens/HomeScreen/Views/MealChartCard.dart';
import 'package:mess/Screens/HomeScreen/Views/RevenueAccountCard.dart';
import 'package:mess/Screens/HomeScreen/Views/RevnueCard.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/Utils/TitleText.dart';


class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final DashboardController dashboardController = Get.put(DashboardController());
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        final stats = dashboardController.dashboardData.value;
        final isLoading = dashboardController.isLoading.value;
        final userName = authController.currentUser.value?.name ?? "Admin";

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (stats == null) {
          return const Center(child: Text("No data available"));
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔹 Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Profile circle with first letter
                    Container(
                      width: 35.w,
                      height: 35.h,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF5F3F3),
                      ),
                      child: Center(
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    // 👇 Dynamic dashboard title
                    TittleText(text: "$userName's Dashboard"),

                    // Notification icon
                    Container(
                      width: 35.w,
                      height: 35.h,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF5F3F3),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.notifications_none,
                          size: 16.sp,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                /// 🔹 Main Revenue Summary Card
                RevenueCard(
                  totalRevenue: stats.totalRevenue,
                  completedOrders: stats.completedOrders,
                  todaysRevenue: stats.todaysRevenue,
                ),

                SizedBox(height: 20.h),

                /// 🔹 Analytics Grid (2x2)
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.h,
                  crossAxisSpacing: 16.w,
                  childAspectRatio: 1.15,
                  children: [
                    AnalyticsCard(
                      icon: Icons.shopping_bag_outlined,
                      iconColor: const Color(0xff6AA84F),
                      bgColor: const Color(0xffF5FBEF),
                      title: 'Total Orders',
                      value: '${stats.totalOrders}',
                    ),
                    AnalyticsCard(
                      icon: Icons.people_outline,
                      iconColor: const Color(0xff00BFA5),
                      bgColor: const Color(0xffE8FFFA),
                      title: 'Customers',
                      value: '${stats.totalCustomers}',
                    ),
                    AnalyticsCard(
                      icon: Icons.group_outlined,
                      iconColor: const Color(0xff009688),
                      bgColor: const Color(0xffECF4F3),
                      title: 'Partners',
                      value: '${stats.totalPartners}',
                      subtitle: '${stats.activePartners} active',
                    ),
                    AnalyticsCard(
                      icon: Icons.account_balance_wallet_outlined,
                      iconColor: const Color(0xffF9A825),
                      bgColor: const Color(0xffFFF8E1),
                      title: 'Avg/Customer',
                      value: '₹${stats.avgPerCustomer.toStringAsFixed(2)}',
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                /// 🔹 Revenue Account Cards
                Row(
                  children: [
                    Expanded(
                      child: RevnueAccountCard(
                        label: 'Pending Revenue',
                        value: '₹${stats.pendingRevenue.toStringAsFixed(2)}',
                        subtitle: 'This Week',
                        bgColor: const Color(0xffFFEDD4),
                        textColor: const Color(0xff7E2A0C),
                        labelColor: const Color(0xFFC34314),
                        subtitleColor: const Color(0xFFC34314),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: RevnueAccountCard(
                        label: 'Total Revenue',
                        value: '₹${stats.totalRevenue.toStringAsFixed(2)}',
                        subtitle: 'This Month',
                        bgColor: const Color(0xffDCFCE7),
                        textColor: const Color(0xff0D542B),
                        labelColor: const Color(0xFF2AD872),
                        subtitleColor: const Color(0xFF2AD872),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 40.h),

                /// 🔹 Meal Chart Card
                const MealChartCard(),

                SizedBox(height: 60.h),
              ],
            ),
          ),
        );
      }),
    );
  }
}
