import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class StepLine extends StatelessWidget {
  final bool active;

  const StepLine({
    super.key,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 1.5,
        color: active
            ? AppColors.primary
            : const Color(0xffD1D5DB),
      ),
    );
  }
}

class StepWidget extends StatelessWidget {
  final String number;
  final String title;
  final bool active;

  const StepWidget({
    super.key,
    required this.number,
    required this.title,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 30.h,
          width: 30.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? AppColors.primary
                : Colors.white,
            border: Border.all(
              color: active
                  ? AppColors.primary
                  : const Color(0xffD1D5DB),
            ),
          ),
          child: Text(
            number,
            style: TextStyle(
              color: active
                  ? Colors.white
                  : const Color(0xff374151),
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
            ),
          ),
        ),

        SizedBox(height: 8.h),

        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: active
                ? FontWeight.w700
                : FontWeight.w500,
            color: active
                ? AppColors.primary
                : const Color(0xff6B7280),
          ),
        ),
      ],
    );
  }
}