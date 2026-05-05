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

  final DashboardController dashboardController =
      Get.put(DashboardController());
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetBuilder<DashboardController>(
        builder: (controller) {
          final stats = controller.dashboardData;
          final isLoading = controller.isLoading;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // ✅ FIXED HEADER
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                child: _buildHeader(context),
              ),

              // ✅ PERFECT SCROLL (NO EXTRA SPACE)
              Expanded(
                child: ListView(
                  physics: const ClampingScrollPhysics(), // no bounce gap
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  children: [
                    SizedBox(height: 10.h),

                    // Revenue Card
                    RevenueCard(
                      totalRevenue: stats?.totalRevenue ?? 0.0,
                      completedOrders: stats?.completedOrders ?? 0,
                      todaysRevenue: stats?.todaysRevenue ?? 0.0,
                    ),

                    SizedBox(height: 20.h),

                    // Analytics
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 20.w,
                      children: [
                        AnalyticsCard(
                          icon: Icons.shopping_bag_outlined,
                          iconColor: const Color(0xff6AA84F),
                          bgColor: const Color(0xffF5FBEF),
                          title: 'Total Orders',
                          value: '${stats?.totalOrders ?? 0}',
                        ),
                        AnalyticsCard(
                          icon: Icons.people_outline,
                          iconColor: const Color(0xff00BFA5),
                          bgColor: const Color(0xffE8FFFA),
                          title: 'Customers',
                          value: '${stats?.totalCustomers ?? 0}',
                        ),
                        AnalyticsCard(
                          icon: Icons.group_outlined,
                          iconColor: const Color(0xff009688),
                          bgColor: const Color(0xffECF4F3),
                          title: 'Partners',
                          value: '${stats?.totalPartners ?? 0}',
                          subtitle:
                              '${stats?.activePartners ?? 0} active',
                        ),
                        AnalyticsCard(
                          icon:
                              Icons.account_balance_wallet_outlined,
                          iconColor: const Color(0xffF9A825),
                          bgColor: const Color(0xffFFF8E1),
                          title: 'Avg/Customer',
                          value:
                              '₹${(stats?.avgPerCustomer ?? 0.0).toStringAsFixed(2)}',
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Revenue split
                    Row(
                      children: [
                        Expanded(
                          child: RevnueAccountCard(
                            label: 'Pending Revenue',
                            value:
                                '₹${(stats?.pendingRevenue ?? 0.0).toStringAsFixed(2)}',
                            subtitle: 'This Week',
                            bgColor: const Color(0xffFFEDD4),
                            textColor: const Color(0xff7E2A0C),
                            labelColor: const Color(0xFFC34314),
                            subtitleColor: const Color(0xFFC34314),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: RevnueAccountCard(
                            label: 'Total Revenue',
                            value:
                                '₹${(stats?.totalRevenue ?? 0.0).toStringAsFixed(2)}',
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
                    const MealChartCard(),
                    SizedBox(height: 20.h), // ✅ minimal bottom space
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context) {
    return GetBuilder<AuthController>(
      initState: (state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (authController.ownedMesses.isEmpty) {
            authController.fetchOwnedMesses();
          }
        });
      },
      builder: (auth) {
        final userName = auth.currentUser?.name ?? "Admin";
        final userEmail =
            auth.currentUser?.email ?? "admin@email.com";
        final messes = auth.ownedMesses;
        final selectedMessId = auth.selectedMessId;

        return Row(
          children: [
            GestureDetector(
              onTap: () =>
                  _showProfileBottomSheet(context, userName, userEmail),
              child: Container(
                width: 38.w,
                height: 38.h,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF5F3F3),
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty
                        ? userName[0].toUpperCase()
                        : 'A',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),

            Expanded(
              child: TittleText(
                text: userName,
                size: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(width: 12.w),

           Container(
  width: 130.w,
  height: 36.h,
  padding: EdgeInsets.symmetric(horizontal: 8.w),
  decoration: BoxDecoration(
    color: const Color(0xFFF5F3F3),
    borderRadius: BorderRadius.circular(12.r),
  ),
  child: auth.isLoading
      ? const Center(
          child: SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        )
      : (messes.length <= 1)
          ? Align(
              alignment: Alignment.centerLeft,
              child: Text(
                messes.isEmpty
                    ? "No Mess"
                    : messes.first["name"] ?? "Unnamed",
                style: TextStyle(fontSize: 12.sp),
                overflow: TextOverflow.ellipsis,
              ),
            )
          : DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedMessId.isNotEmpty
                    ? selectedMessId
                    : null,
                hint: Text(
                  "Select Mess",
                  style: TextStyle(fontSize: 12.sp),
                ),

                // 🔥 KEY FIX
                isDense: true,
                icon: const Icon(Icons.keyboard_arrow_down, size: 18),

                items: messes.map((mess) {
                  return DropdownMenuItem<String>(
                    value: mess["id"].toString(),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        mess["name"] ?? "Unnamed",
                        style: TextStyle(fontSize: 12.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),

                onChanged: (value) async {
                  if (value != null) {
                    auth.selectedMessId = value;
                    auth.update();

                    final prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setString("selectedMessId", value);

                    dashboardController.fetchDashboardStats();
                  }
                },
              ),
            ),
)
          ],
        );
      },
    );
  }
  // ================= PROFILE =================
 void _showProfileBottomSheet(
    BuildContext context, String userName, String userEmail) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 30.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔘 Drag Handle
            Container(
              width: 50.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),

            SizedBox(height: 20.h),

            // 👤 Profile Row
            Row(
              children: [
                CircleAvatar(
                  radius: 28.r,
                  backgroundColor: const Color(0xFFF1F1F1),
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
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        userEmail,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 25.h),

            Divider(color: Colors.grey[200]),

            SizedBox(height: 10.h),

            // 🚪 Logout Button
            SizedBox(
              width: double.infinity,
              height: 45.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showLogoutDialog(context, authController);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  "Logout",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

// ================= LOGOUT =================
void _showLogoutDialog(
    BuildContext context, AuthController authController) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Confirm Logout"),
      content:
          const Text("Are you sure you want to log out?"),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await authController.logout();
          },
          child: const Text("Logout"),
        ),
      ],
    ),
  );
}}