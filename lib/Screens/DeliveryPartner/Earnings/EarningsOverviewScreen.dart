// DELIVERY PARTNER MODULE — DISABLED (admin-only build for now)
// Entire file commented out below; not wired into the app.
/*
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mess/Screens/DeliveryPartner/Earnings/Service/MockEarningsController.dart';
import 'package:mess/Screens/DeliveryPartner/Earnings/Views/EarningsTransactionsScreen.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class EarningsOverviewScreen extends StatelessWidget {
  const EarningsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MockEarningsController());
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GetBuilder<MockEarningsController>(
          builder: (ctrl) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Earnings",
                        style: GoogleFonts.poppins(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      Icon(Icons.calendar_today_outlined, size: 18.sp, color: Colors.grey.shade600),
                    ],
                  ),
                  Text(
                    "${DateFormat('dd MMM yyyy').format(weekStart)} - ${DateFormat('dd MMM yyyy').format(weekEnd)}",
                    style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey.shade500),
                  ),

                  SizedBox(height: 16.h),

                  /// ---------- TOTAL EARNINGS ----------
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(18.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
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
                            Icons.account_balance_wallet_rounded,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total Earnings",
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            Text(
                              "₹${ctrl.totalEarnings.toStringAsFixed(0)}",
                              style: GoogleFonts.poppins(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  /// ---------- STATS ----------
                  Row(
                    children: [
                      _statTile(
                        icon: Icons.local_shipping_outlined,
                        color: const Color(0xFF2E61D8),
                        label: "Deliveries",
                        value: "${ctrl.deliveriesCount}",
                      ),
                      SizedBox(width: 10.w),
                      _statTile(
                        icon: Icons.check_circle_outline,
                        color: AppColors.success,
                        label: "Paid",
                        value: "${ctrl.paidCount}",
                      ),
                      SizedBox(width: 10.w),
                      _statTile(
                        icon: Icons.hourglass_bottom_outlined,
                        color: AppColors.warning,
                        label: "Balance",
                        value: "₹${ctrl.pendingTotal.toStringAsFixed(0)}",
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  Text(
                    "Earnings Breakdown",
                    style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 10.h),
                  _breakdownRow("Total Delivery Earnings", ctrl.totalEarnings),
                  _breakdownRow("Payment Received", ctrl.paidTotal),
                  _breakdownRow("Balance to Collect", ctrl.pendingTotal, isWarning: true),

                  SizedBox(height: 20.h),

                  Text(
                    "Daily Earnings (This Week)",
                    style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(height: 140.h, child: _WeeklyBarChart(data: ctrl.weekly)),

                  SizedBox(height: 20.h),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Get.to(() => const EarningsTransactionsScreen()),
                      icon: Icon(Icons.receipt_long_outlined, size: 16.sp, color: AppColors.primary),
                      label: Text(
                        "View All Transactions",
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
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

  Widget _statTile({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18.sp),
            SizedBox(height: 6.h),
            Text(
              value,
              style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w700),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _breakdownRow(String label, double amount, {bool isWarning = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey.shade600),
          ),
          Text(
            "₹${amount.toStringAsFixed(0)}",
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: isWarning ? Colors.red.shade400 : const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  final List data;

  const _WeeklyBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxY = data.fold<double>(0, (m, d) => d.amount > m ? d.amount : m) * 1.2;

    return BarChart(
      BarChartData(
        maxY: maxY == 0 ? 100 : maxY,
        alignment: BarChartAlignment.spaceAround,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Text(
                    data[index].day,
                    style: GoogleFonts.poppins(fontSize: 9.sp, color: Colors.grey.shade600),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(data.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i].amount,
                color: AppColors.primary,
                width: 16.w,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ],
          );
        }),
      ),
    );
  }
}

*/
