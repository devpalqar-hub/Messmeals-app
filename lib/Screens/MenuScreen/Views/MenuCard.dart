import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mess/Screens/MenuScreen/Models/MenuModel.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class MenuCard extends StatelessWidget {
  final MenuModel menu;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MenuCard({
    super.key,
    required this.menu,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final activeDays = kMenuWeekDays
        .where((day) => (menu.schedule[day]?.isNotEmpty ?? false))
        .map((day) => kMenuWeekDayLabels[day]!.substring(0, 3))
        .toList();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  menu.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
              if (!menu.isActive)
                Container(
                  margin: EdgeInsets.only(right: 8.w),
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    "Inactive",
                    style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.grey.shade600),
                  ),
                ),
              Row(
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: Icon(Icons.edit_outlined, size: 16.sp, color: Colors.grey.shade700),
                  ),
                  SizedBox(width: 10.w),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(Icons.delete_outline, size: 16.sp, color: Colors.red.shade400),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            "${menu.totalEntries} entries across ${activeDays.length} day(s)",
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: activeDays.map((day) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  day,
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
