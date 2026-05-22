
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class CustomerCard extends StatelessWidget {
  final String name;
  final String phone;
  final String initials;

  const CustomerCard({
    super.key,
    required this.name,
    required this.phone,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:  EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 14.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: const Color(0xffececec),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          /// Avatar
          Container(
            height: 40.h,
            width: 40.w,
            decoration: const BoxDecoration(
              color: Color(0xffe8f5ef),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                color:AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
              ),
            ),
          ),

           SizedBox(width: 16),

          /// Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style:  TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff111827),
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 16,
                      color: Color(0xff6b7280),
                    ),
                     SizedBox(width: 5.w),
                    Text(
                      phone,
                      style:  TextStyle(
                        fontSize: 14.sp,
                        color: Color(0xff4b5563),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// Arrow
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: Color(0xff111827),
          ),
        ],
      ),
    );
  }
}