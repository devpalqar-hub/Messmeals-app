import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RevenueCard extends StatelessWidget {
  final double? totalRevenue;     
  final int? completedOrders;     
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
      width: 360.w,
      height: 160.h,
      decoration: BoxDecoration(
        color: const Color(0xff5B9A9E),
        borderRadius: BorderRadius.circular(24.0),
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
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Revenue',
              style: TextStyle(
                fontSize: 16.0,
                fontFamily: "Inter",
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8.0),
  Text(
              '₹${(totalRevenue ?? 0).toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 26.0,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: "Inter",
              ),
            ),
            const SizedBox(height: 6.0),

            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 20.sp,
                ),
                const SizedBox(width: 6),
                Text(
                  completedOrders != null
                      ? '${completedOrders} completed orders'
                      : 'Today’s Revenue: ₹${(todaysRevenue ?? 0).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.white,
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
