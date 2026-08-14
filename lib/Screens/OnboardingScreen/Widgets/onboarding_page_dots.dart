import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mess/Screens/Utils/Colors.dart';

/// Page indicator: inactive pages render as small grey dots, the active
/// page widens into a teal pill. Animates every time [currentPage] changes.
class OnboardingPageDots extends StatelessWidget {
  final int pageCount;
  final int currentPage;

  const OnboardingPageDots({
    super.key,
    required this.pageCount,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final active = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          height: 8.h,
          width: active ? 26.w : 8.w,
          decoration: BoxDecoration(
            color: active ? primaryTeal : const Color(0xFFDADEE3),
            borderRadius: BorderRadius.circular(20.r),
          ),
        );
      }),
    );
  }
}
