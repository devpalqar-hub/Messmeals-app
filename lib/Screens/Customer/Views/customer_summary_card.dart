import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mess/Screens/CustomerScreen/Model/CustomerModel.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

/// Compact 3-tile summary strip for the Customers page header:
/// active subscriptions, subscriptions ending within 7 days, and the
/// total amount the mess still needs to collect back from customers.
class CustomerSummaryCard extends StatelessWidget {
  final CustomerSummaryModel summary;
  final bool isLoading;

  const CustomerSummaryCard({
    super.key,
    required this.summary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Tile(
            icon: Icons.groups_outlined,
            iconColor: AppColors.primaryDark,
            iconBgColor: const Color(0xffe8f5ef),
            label: "Active Subscriptions",
            value: isLoading ? "-" : "${summary.activeSubscriptionsCount}",
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _Tile(
            icon: Icons.hourglass_bottom_rounded,
            iconColor: AppColors.warning,
            iconBgColor: const Color(0xffFEF3E2),
            label: "Ending in 7 Days",
            value: isLoading ? "-" : "${summary.endingSoonCount}",
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _Tile(
            icon: Icons.currency_rupee_rounded,
            iconColor: AppColors.error,
            iconBgColor: const Color(0xffFDECEC),
            label: "To Collect",
            value: isLoading ? "-" : "₹${summary.totalDue.toStringAsFixed(0)}",
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String label;
  final String value;

  const _Tile({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xffececec)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 28.w,
            width: 28.w,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(icon, color: iconColor, size: 15.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xff111827),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10.sp, color: const Color(0xff6b7280)),
          ),
        ],
      ),
    );
  }
}
