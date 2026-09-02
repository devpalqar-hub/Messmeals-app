import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String label;
  final String value;

  const StatItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 35.w,
            width: 35.w,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Center(child: Icon(icon, color: iconColor, size: 18)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: Color(0xFF6B7280), // Medium Gray
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              color: Color(0xFF1F2937), // Very Dark Gray
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class DividerWidget extends StatelessWidget {
  const DividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      width: 1.2,
      color: const Color(0xFFEEEEEE), // Very Light Gray
    );
  }
}

class RevenueCard extends StatelessWidget {
  final String title;
  final String amount;
  final String period;
  final IconData icon;
  final Color themeColor;
  final Color iconBgColor;
  final Color cardBgColor;

  const RevenueCard({
    super.key,
    required this.title,
    required this.amount,
    required this.period,
    required this.icon,
    required this.themeColor,
    required this.iconBgColor,
    required this.cardBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F3F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 30.w,
            width: 30.w,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: themeColor, size: 22),
          ),
          SizedBox(width: 8.h),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Color(0xFF6B7280), // Medium Gray
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Color(0xFF111827), // Very Dark Gray
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  period,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: themeColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const QuickActionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F3F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 38.w,
            width: 38.w,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8), // Soft rounded inner box
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: Color(0xFF111827), // Dark Gray
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
