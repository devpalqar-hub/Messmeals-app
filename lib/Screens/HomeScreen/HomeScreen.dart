import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/HomeScreen/Views/AnalyticsCard.dart';
import 'package:mess/Screens/HomeScreen/Views/MealChartCard.dart';
import 'package:mess/Screens/HomeScreen/Views/RevenueAccountCard.dart';
import 'package:mess/Screens/HomeScreen/Views/RevnueCard.dart';
import 'package:mess/Screens/LoginScreen/Service/LoginController.dart';
import 'package:mess/Screens/Utils/TitleText.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final DashboardController dashboardController = Get.put(DashboardController());
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        final stats = dashboardController.dashboardData.value;
        final isLoading = dashboardController.isLoading.value;
        final userName = authController.currentUser.value?.name ?? "Admin";
        final userEmail = authController.currentUser.value?.email ?? "admin@email.com";

        // ✅ Use default values if stats is null
        final totalRevenue = stats?.totalRevenue ?? 0.0;
        final completedOrders = stats?.completedOrders ?? 0;
        final todaysRevenue = stats?.todaysRevenue ?? 0.0;
        final totalOrders = stats?.totalOrders ?? 0;
        final totalCustomers = stats?.totalCustomers ?? 0;
        final totalPartners = stats?.totalPartners ?? 0;
        final activePartners = stats?.activePartners ?? 0;
        final avgPerCustomer = stats?.avgPerCustomer ?? 0.0;
        final pendingRevenue = stats?.pendingRevenue ?? 0.0;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
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
                    // 👤 Profile icon
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                          ),
                          backgroundColor: Colors.white,
                          builder: (context) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.h),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 60.w,
                                    height: 6.h,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  SizedBox(height: 20.h),
                                  Row(
                                    children: [
                                      Container(
                                        width: 50.w,
                                        height: 50.h,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF5F3F3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            userName.isNotEmpty
                                                ? userName[0].toUpperCase()
                                                : 'A',
                                            style: GoogleFonts.poppins(
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            userName,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                          Text(
                                            userEmail,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12.sp,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 25.h),
                                  Divider(color: Colors.grey[300]),
                                  SizedBox(height: 10.h),

                                  // 🚪 Logout button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _showLogoutDialog(context, authController);
                                      },
                                      icon: const Icon(Icons.logout, color: Colors.white),
                                      label: Text(
                                        "Logout",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                        padding: EdgeInsets.symmetric(vertical: 12.h),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 15.h),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
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
                    ),

                    /// 🔹 Dashboard title
                    TittleText(text: userName),

                    /// 🔹 Dropdown for mess selection
                    Obx(() {
                      final messes = authController.ownedMesses;
                      final selectedMessId = authController.selectedMessId.value;

                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F3F3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedMessId.isNotEmpty ? selectedMessId : null,
                            hint: Text(
                              messes.isEmpty ? "No Messes" : "Select Mess",
                              style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                            ),
                            items: messes
                                .map((mess) => DropdownMenuItem<String>(
                                      value: mess["id"],
                                      child: Text(
                                        mess["name"] ?? "Unnamed",
                                        style: TextStyle(fontSize: 12.sp),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) async {
                              if (value != null) {
                                authController.selectedMessId.value = value;
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.setString("selectedMessId", value);
                              }
                            },
                          ),
                        ),
                      );
                    }),
                  ],
                ),

                SizedBox(height: 20.h),

                /// 🔹 Main Revenue Summary Card
                RevenueCard(
                  totalRevenue: totalRevenue,
                  completedOrders: completedOrders,
                  todaysRevenue: todaysRevenue,
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
                      value: '$totalOrders',
                    ),
                    AnalyticsCard(
                      icon: Icons.people_outline,
                      iconColor: const Color(0xff00BFA5),
                      bgColor: const Color(0xffE8FFFA),
                      title: 'Customers',
                      value: '$totalCustomers',
                    ),
                    AnalyticsCard(
                      icon: Icons.group_outlined,
                      iconColor: const Color(0xff009688),
                      bgColor: const Color(0xffECF4F3),
                      title: 'Partners',
                      value: '$totalPartners',
                      subtitle: '$activePartners active',
                    ),
                    AnalyticsCard(
                      icon: Icons.account_balance_wallet_outlined,
                      iconColor: const Color(0xffF9A825),
                      bgColor: const Color(0xffFFF8E1),
                      title: 'Avg/Customer',
                      value: '₹${avgPerCustomer.toStringAsFixed(2)}',
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
                        value: '₹${pendingRevenue.toStringAsFixed(2)}',
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
                        value: '₹${totalRevenue.toStringAsFixed(2)}',
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

/// 🔹 Logout confirmation dialog
void _showLogoutDialog(BuildContext context, AuthController authController) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text("Confirm Logout"),
      content: const Text("Are you sure you want to log out?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          onPressed: () async {
            Navigator.pop(context);
            await authController.logout();
          },
          child: const Text("Logout"),
        ),
      ],
    ),
  );
}
