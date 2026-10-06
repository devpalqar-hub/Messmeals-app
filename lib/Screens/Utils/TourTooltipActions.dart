import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:mess/Screens/Utils/AppColors.dart';
import 'package:mess/Screens/Utils/AppTourController.dart';

/// Shared look for every tooltip in the guided tour — bold black title,
/// muted grey description, generously rounded white card. Applied
/// explicitly on every `Showcase` rather than left to package defaults,
/// so every stop renders identically.
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

/// Breathing room between the "Tap here to …" title and its description.
EdgeInsets tourDescPadding() => EdgeInsets.only(top: 10.h);

BorderRadius tourTooltipBorderRadius() => BorderRadius.circular(16);

// ---------------------------------------------------------------------------
// Highlight shape + animation — the "spotlight" look shared by every stop.
// ---------------------------------------------------------------------------

/// Rounded-square highlight around whatever's spotlighted, with enough
/// padding that small targets (an edit/delete icon) get a roomy square
/// cutout instead of hugging the icon's own tight bounds.
BorderRadius tourTargetBorderRadius() => BorderRadius.circular(14);
EdgeInsets tourTargetPadding() => const EdgeInsets.all(8);

/// Deep app-green backdrop (instead of plain black) so the tour reads as
/// part of the app rather than a generic overlay, plus a touch of blur for
/// depth. `Get.put`s the mess owner into the moment, not just dims the rest.
Color tourOverlayColor() => const Color(0xFF0E2B0A);
double tourOverlayOpacity() => 0.85;
double tourBlurValue() => 1.5;

/// A little bounce on the way in, and a smooth glide from one spotlighted
/// target to the next — the "interesting to watch" motion.
Duration tourScaleAnimationDuration() => const Duration(milliseconds: 380);
Curve tourScaleAnimationCurve() => Curves.easeOutBack;
Duration tourMovingAnimationDuration() => const Duration(milliseconds: 550);

EdgeInsets tourTooltipPadding() => EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h);

/// Builds the "End Tour   step/total   Next" action row shown at the bottom
/// of every tooltip.
///
/// Returned as THREE separate actions rather than one wide widget: the
/// package lays actions out in a Row that hands each child unbounded width
/// (so `Expanded` inside one would crash the tooltip), and spreads them
/// with `spaceBetween`. End Tour and Next share one fixed width, so the
/// step counter lands exactly in the middle with equal space either side.
///
/// [tourId] says which tour this stop belongs to, so "End Tour" marks that
/// tour (and only that one) as seen.
List<TooltipActionButton> tourTooltipActions(
  BuildContext context, {
  required int step,
  required int total,
  String tourId = AppTourController.homeTour,

  /// Runs after "Done" is tapped on the last stop — used to chain the next
  /// tour on from this one.
  VoidCallback? onDone,
}) {
  final isLast = step == total;
  final sideWidth = 92.w;
  final rowGap = 26.h;

  void endTour() {
    AppTourController.instance.markSeen(tourId);
    ShowCaseWidget.of(context).dismiss();
  }

  return [
    TooltipActionButton.custom(
      button: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: endTour,
        child: Padding(
          padding: EdgeInsets.only(top: rowGap, bottom: 6.h),
          child: SizedBox(
            width: sideWidth,
            child: Text(
              'End Tour',
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                color: const Color(0xFFE5484D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    ),
    TooltipActionButton.custom(
      button: Padding(
        padding: EdgeInsets.only(top: rowGap, bottom: 6.h),
        child: Text(
          '$step/$total',
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
    TooltipActionButton.custom(
      button: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ShowCaseWidget.of(context).next();
          if (isLast) onDone?.call();
        },
        child: Padding(
          padding: EdgeInsets.only(top: rowGap, bottom: 6.h),
          child: SizedBox(
            width: sideWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
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
        ),
      ),
    ),
  ];
}
