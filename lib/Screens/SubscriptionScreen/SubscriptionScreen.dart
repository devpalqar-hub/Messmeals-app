import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:get/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess/Screens/SubscriptionScreen/Controller/SubscriptionControllrer.dart';
import 'package:mess/Screens/SubscriptionScreen/Views/SubscrptionCards.dart';
import 'package:mess/Screens/Utils/Colors.dart';

class SubscriptionScreen extends StatelessWidget {
  SubscriptionScreen({super.key});

  // Theme Colors based on the design
  final Color primaryTeal = const Color(0xFF0F766E);
  final Color textDark = const Color(0xFF1E293B);
  final Color textLight = const Color(0xFF64748B);
  final Color cardBg = Colors.white;

  SubscriptionControllrer ctrl = Get.put(SubscriptionControllrer());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscriptionControllrer>(
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              'Subscription',

              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
          ),
          body:
              (ctrl.billingModel == null)
                  ? Center(
                    child: CircularProgressIndicator(color: PrimaryColor),
                  )
                  : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 16.h,
                      children: [
                        //_buildHeaderSection(),
                        // SizedBox(height: 20.h),
                        // _buildUsageOverviewCard(),
                        NextBillCard(),
                        _buildPricingChartCard(),
                        //_buildFooterInfo(),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
        );
      },
    );
  }

  // --- 1. Header Section (Plan & Expiry) ---
  Widget _buildHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.workspace_premium_outlined,
                  color: primaryTeal,
                  size: 20.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  'Premium Plan',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: primaryTeal,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE), // Light Blue/Green bg
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                'Active',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: primaryTeal,
                ),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Expires on',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: textLight,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              '01 Aug 2024',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: primaryTeal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- 2. Usage Overview Card ---
  Widget _buildUsageOverviewCard() {
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people_outline, color: textLight, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Usage Overview ',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
              Text(
                '(Last Month)',
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: textLight,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              // Circular Chart
              SizedBox(
                height: 110.w,
                width: 110.w,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 0.72,
                      strokeWidth: 8.w,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(primaryTeal),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '72',
                            style: GoogleFonts.poppins(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          Text(
                            'of 100\nCustomers Used',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w500,
                              color: textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 24.w),
              // Stats
              Expanded(
                child: Column(
                  children: [
                    _buildUsageRow('Customer Limit', '100', true),
                    SizedBox(height: 12.h),
                    _buildUsageRow('Used (01 Apr – 30 Apr 2024)', '72', true),
                    SizedBox(height: 12.h),
                    _buildUsageRow('Remaining', '28', true),
                    SizedBox(height: 12.h),
                    _buildUsageRow('Usage', '72%', false, isGreen: true),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageRow(
    String label,
    String value,
    bool isBoldValue, {
    bool isGreen = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12.sp, color: textLight),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: isBoldValue ? FontWeight.w600 : FontWeight.w500,
            color: isGreen ? primaryTeal : textDark,
          ),
        ),
      ],
    );
  }

  // --- 3. Next Bill Card ---

  Widget _buildBillStat(String label, String value, {bool isAmount = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10.sp,
            color: textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isAmount ? 16.sp : 13.sp,
            fontWeight: FontWeight.w600,
            color: isAmount ? primaryTeal : textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildDividerVertical() {
    return Container(height: 30.h, width: 1, color: const Color(0xFFE2E8F0));
  }

  // --- 4. Pricing Chart Card ---
  Widget _buildPricingChartCard() {
    return _BaseCard(
      padding: EdgeInsets.zero, // Padding handled individually for rows
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Icon(Icons.bar_chart, color: textLight, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Pricing Chart',
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
              ],
            ),
          ),
          // Table Header
          Container(
            color: const Color(0xFFF8FAFC),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              children: [
                Expanded(flex: 2, child: _tableHeaderText('Customer Range')),
                Expanded(flex: 1, child: _tableHeaderText('Rate / Customer')),
                Expanded(
                  flex: 1,
                  child: _tableHeaderText(
                    'Amount (for last month)',
                    isRight: true,
                  ),
                ),
              ],
            ),
          ),
          // Table Rows
          for (var data in ctrl.billingTier)
            _buildPricingRow(
              '${data.minCustomers} - ${data.minCustomers}',
              '₹ ${data.perCustomerRate}',
              '₹ ${(double.parse(data.perCustomerRate!) * ctrl.billingModel!.customerCount!).toString()}',
              isCurrent:
                  data.perCustomerRate ==
                  ctrl.billingModel!.perCustomerRate.toString(),
              isLast:
                  ctrl.billingTier.indexOf(data) == ctrl.billingTier.length - 1,
            ),
          // _buildPricingRow('51 - 100', '₹ 22', '₹ 484', isCurrent: true),
          // _buildPricingRow('101 - 250 ', '₹ 20', '-'),
          // _buildPricingRow('251 - 500', '₹ 18', '-'),
          // _buildPricingRow('501+ ', '₹ 15', '-', isLast: true),

          // Padding(
          //   padding: EdgeInsets.all(16.w),
          //   child: Text(
          //     '* Amount calculated for last month usage (72 customers)',
          //     style: GoogleFonts.poppins(fontSize: 10.sp, color: textLight),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _tableHeaderText(String text, {bool isRight = false}) {
    return Text(
      text,
      textAlign: isRight ? TextAlign.right : TextAlign.left,
      style: GoogleFonts.poppins(
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        color: textLight,
      ),
    );
  }

  Widget _buildPricingRow(
    String range,
    String rate,
    String amount, {
    bool isCurrent = false,
    bool isLast = false,
  }) {
    return Container(
      // Faint green if active
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xFFF0FDF4) : Colors.white,
        border:
            isLast
                ? null
                : const Border(
                  bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text(
                  range,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isCurrent) ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'Current',
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        color: primaryTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              rate,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              amount,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 5. Footer Info Section ---
  Widget _buildFooterInfo() {
    return _BaseCard(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFooterItem(Icons.event_available, 'Started On', '01 May 2024'),
          _buildFooterItem(
            Icons.autorenew,
            'Auto Renew',
            'Enabled',
            isEnabled: true,
          ),
          _buildFooterItem(Icons.credit_card, 'Billing Cycle', 'Monthly'),
        ],
      ),
    );
  }

  Widget _buildFooterItem(
    IconData icon,
    String title,
    String value, {
    bool isEnabled = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: primaryTeal, size: 20.sp),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 10.sp, color: textLight),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isEnabled ? primaryTeal : textDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// --- Reusable Card Container ---
class _BaseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _BaseCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
