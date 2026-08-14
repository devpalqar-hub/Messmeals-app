import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mess/Screens/OnboardingScreen/Model/onboarding_page_data.dart';
import 'package:mess/Screens/OnboardingScreen/Service/onboarding_controller.dart';
import 'package:mess/Screens/OnboardingScreen/Widgets/onboarding_mockup_stack.dart';
import 'package:mess/Screens/OnboardingScreen/Widgets/onboarding_page_dots.dart';
import 'package:mess/Screens/Utils/Colors.dart';

/// 4-page onboarding flow shown once on first launch (before the user
/// has ever logged in) — introduces the mess owner to revenue tracking,
/// customers, plans, deliveries and partners before sending them to login.
class OnboardingScreen extends StatelessWidget {
  OnboardingScreen({super.key});

  final OnboardingController controller = Get.put(OnboardingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardBg,
      body: GetBuilder<OnboardingController>(
        builder: (_) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primaryTeal.withValues(alpha: 0.10),
                  cardBg,
                ],
                stops: const [0.0, 0.55],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  /// SKIP
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 8.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: controller.skip,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 8.h,
                            ),
                            child: Text(
                              "Skip",
                              style: GoogleFonts.poppins(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w600,
                                color: textDark,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                 

                  /// SWIPEABLE PAGE CONTENT
                  Expanded(
                    child: PageView.builder(
                      controller: controller.pageController,
                      itemCount: controller.pages.length,
                      onPageChanged: controller.onPageChanged,
                      itemBuilder: (context, index) {
                        final page = controller.pages[index];
                        final active = index == controller.currentPage;
                        return _OnboardingPageBody(page: page, active: active);
                      },
                    ),
                  ),

                  /// DOTS
                  OnboardingPageDots(
                    pageCount: controller.pages.length,
                    currentPage: controller.currentPage,
                  ),

                  SizedBox(height: 22.h),

                  /// CTA
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: SizedBox(
                      width: double.infinity,
                      height: 58.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                        ),
                        onPressed: controller.next,
                        child: Text(
                          controller.pages[controller.currentPage].buttonLabel,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).padding.bottom + 18.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Content of a single onboarding page: mockup + floating card, title
/// and subtitle. Fades and slides up into place whenever it becomes the
/// active page. The chip row is not part of this — it's a separate
/// master strip rendered once above the PageView.
class _OnboardingPageBody extends StatelessWidget {
  final OnboardingPageData page;
  final bool active;

  const _OnboardingPageBody({required this.page, required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
      opacity: active ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOutCubic,
        offset: active ? Offset.zero : const Offset(0, 0.06),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            child: Column(
              children: [
                OnboardingMockupStack(
                  mockupAsset: page.mockupAsset,
                  cardAsset: page.cardAsset,
                  cardAlignment: page.cardAlignment,
                  cardOverlap: page.cardOverlap,
                  cardWidthFraction: page.cardWidthFraction,
                ),
                SizedBox(height: 36.h),
                Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  page.subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    color: textLight,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
