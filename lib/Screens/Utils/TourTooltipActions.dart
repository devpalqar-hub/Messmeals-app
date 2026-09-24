import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:mess/Screens/Utils/AppColors.dart';
import 'package:mess/Screens/Utils/AppTourController.dart';

/// Shared look for every tooltip in the guided tour — bold black title,
/// muted grey description, generously rounded white card. Applied
/// explicitly on every `Showcase` rather than left to package defaults,
/// so all 8 stops render identically.
TextStyle tourTitleStyle() => GoogleFonts.poppins(
  fontSize: 17.sp,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF111827),
);

TextStyle tourDescStyle() => GoogleFonts.poppins(
  fontSize: 14.sp,
  height: 1.4,
  fontWeight: FontWeight.w400,
  color: Colors.grey.shade700,
);

BorderRadius tourTooltipBorderRadius() => BorderRadius.circular(16);

EdgeInsets tourTooltipPadding() => EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 16.h);

/// Builds the "End Tour · step/total · Next" action row shown at the
/// bottom of every tooltip in the guided app tour — one custom action
/// widget spanning the full tooltip width, laid out to match.
List<TooltipActionButton> tourTooltipActions(
  BuildContext context, {
  required int step,
  required int total,
}) {
  final isLast = step == total;

  void endTour() {
    AppTourController.instance.markSeen();
    ShowCaseWidget.of(context).dismiss();
  }

  return [
    TooltipActionButton.custom(
      button: Padding(
        // Wide side insets + tall top gap so End Tour / step count / Next
        // sit clearly apart, the way the reference tooltip lays them out.
        padding: EdgeInsets.only(top: 26.h, left: 14.w, right: 14.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: endTour,
              child: Text(
                'End Tour',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '$step/$total',
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: () => ShowCaseWidget.of(context).next(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLast ? 'Done' : 'Next',
                    style: GoogleFonts.poppins(
                      fontSize: 16.5.sp,
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!isLast)
                    Icon(
                      Icons.chevron_right,
                      size: 22.sp,
                      color: AppColors.primaryDark,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ];
}
