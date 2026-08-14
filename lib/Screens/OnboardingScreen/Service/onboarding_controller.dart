import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mess/Screens/LoginScreen/LoginScreen.dart';
import 'package:mess/Screens/OnboardingScreen/Model/onboarding_page_data.dart';

/// SharedPreferences key marking that the user has completed (or
/// skipped) onboarding at least once — checked once in `main.dart` so
/// it's never shown again after the first launch.
const String onboardingSeenKey = "ONBOARDING_SEEN";

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  int currentPage = 0;

  // Single master chip strip — one chip per page, in page order. The
  // chip at `currentPage` is always the active/centered one; there is no
  // per-page chip array anymore. Partners doesn't get its own chip —
  // page 4's copy already covers it.
  final List<OnboardingChipData> chips = const [
    OnboardingChipData(icon: Icons.trending_up_rounded, label: "Revenue"),
    OnboardingChipData(icon: Icons.groups_rounded, label: "Customers"),
    OnboardingChipData(icon: Icons.receipt_long_rounded, label: "Plans"),
    OnboardingChipData(icon: Icons.local_shipping_rounded, label: "Deliveries"),
  ];

  final List<OnboardingPageData> pages = [
    OnboardingPageData(
      mockupAsset: "assets/onboarding/onboard_1.png",
      cardAsset: "assets/onboarding/card_1.png",
      cardAlignment: Alignment.bottomLeft,
      cardOverlap: const Offset(-0.30, 0.25),
      cardWidthFraction: 0.40,
      title: "Your Mess, Fully in Control",
      subtitle:
          "Track revenue, orders and customer count from one clean dashboard.",
      buttonLabel: "Get Started",
    ),
    OnboardingPageData(
      mockupAsset: "assets/onboarding/onboard_2.png",
      cardAsset: "assets/onboarding/card_2.png",
      cardAlignment: Alignment.topRight,
      cardOverlap: const Offset(0.28, -0.25),
      cardWidthFraction: 0.40,
      title: "Manage Every Customer",
      subtitle: "Add customers, assign plans and manage wallets in a few taps.",
      buttonLabel: "Next",
    ),
    OnboardingPageData(
      mockupAsset: "assets/onboarding/onboard_3.png",
      cardAsset: "assets/onboarding/card_3.png",
      cardAlignment: Alignment.centerLeft,
      cardOverlap: const Offset(-0.32, 0.0),
      cardWidthFraction: 0.44,
      title: "Build Your Meal Plans",
      subtitle: "Set up daily or monthly plans with breakfast, lunch and dinner.",
      buttonLabel: "Next",
    ),
    OnboardingPageData(
      mockupAsset: "assets/onboarding/onboard_4.png",
      cardAsset: "assets/onboarding/card_4.png",
      cardAlignment: Alignment.bottomRight,
      cardOverlap: const Offset(0.28, 0.25),
      cardWidthFraction: 0.44,
      title: "Deliver Without the Chaos",
      subtitle:
          "Assign partners, track daily deliveries and know what to prepare.",
      buttonLabel: "Login Now",
    ),
  ];

  bool get isLastPage => currentPage == pages.length - 1;

  /// Wired to PageView's onPageChanged — fires on swipe AND on the
  /// programmatic nextPage() call from the CTA button, so both stay in sync.
  void onPageChanged(int index) {
    currentPage = index;
    update();
  }

  Future<void> next() async {
    if (isLastPage) {
      await _finish();
      return;
    }
    await pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> skip() async {
    await _finish();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardingSeenKey, true);
    Get.offAll(() => LoginScreen());
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
