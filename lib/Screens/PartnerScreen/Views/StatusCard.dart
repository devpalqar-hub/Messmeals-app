import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatsCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const StatsCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ---------- ICON + LABEL ----------
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.all(8.w),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: const Color(0xff717182),
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          /// ---------- VALUE ----------
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              fontFamily: "Inter",
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
