import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RevnueAccountCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final Color bgColor;
  final Color textColor;
  final Color? labelColor;     // ✅ new optional color for label text
  final Color? subtitleColor;  // ✅ optional custom color for subtitle

  const RevnueAccountCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    required this.bgColor,
    required this.textColor,
    this.labelColor,           // ✅ new param
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// ✅ Label text (top line)
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: labelColor ?? Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 8.h),

          /// ✅ Main Value text
          Text(
            value,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),

          /// ✅ Optional Subtitle
          if (subtitle != null) ...[
            SizedBox(height: 4.h),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12.sp,
                color: subtitleColor ?? Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
