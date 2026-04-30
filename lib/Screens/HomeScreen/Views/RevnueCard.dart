import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RevenueCard extends StatelessWidget {
  final double? totalRevenue;
  final int? completedOrders; // (not used now, but keep for future)
  final double? todaysRevenue;

  const RevenueCard({
    super.key,
    this.totalRevenue,
    this.completedOrders,
    this.todaysRevenue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xff5B9A9E),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 20.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Text(
              'Total Revenue',
              style: TextStyle(
                fontSize: 15.sp,
                fontFamily: "Inter",
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 8.h),

            /// Amount ONLY (orders removed)
            Text(
              '₹${(totalRevenue ?? 0).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: "Inter",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
