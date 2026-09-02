import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

/// Centered "nothing here yet" empty state with a call-to-action button that starts the
/// same add flow as the screen's header button. Used by list screens (Plans, Menus,
/// Partners, Customers) so the very first record can be created right from the empty list.
class EmptyStateAddButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onAdd;

  const EmptyStateAddButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36.sp, color: AppColors.primary),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey.shade500),
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: Icon(Icons.add, size: 18.sp, color: Colors.white),
              label: Text(
                buttonLabel,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 13.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
