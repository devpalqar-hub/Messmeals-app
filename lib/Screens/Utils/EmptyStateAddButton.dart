import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess/Screens/Utils/AppColors.dart';
import 'package:mess/Screens/Utils/Bottombar.dart' show tintedIcon;

/// Centered "nothing here yet" empty state. Used by list screens (Plans, Menus,
/// Partners, Customers, Deliveries). When [buttonLabel]/[onAdd] are given, it also shows
/// a call-to-action button that starts the same add flow as the screen's header button;
/// screens with no manual "add" flow (e.g. Deliveries, which are generated from
/// subscriptions) can omit them to show just the icon and message.
///
/// [iconAsset] mirrors the screen's own bottom-nav tab icon, so the empty state reads as
/// "this tab" rather than a generic placeholder.
class EmptyStateAddButton extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onAdd;

  const EmptyStateAddButton({
    super.key,
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onAdd,
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
              child: tintedIcon(iconAsset, AppColors.primary, 36.sp),
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
            if (buttonLabel != null && onAdd != null) ...[
              SizedBox(height: 20.h),
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: Icon(Icons.add, size: 18.sp, color: Colors.white),
                label: Text(
                  buttonLabel!,
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 25.w,
                    vertical: 13.h,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
