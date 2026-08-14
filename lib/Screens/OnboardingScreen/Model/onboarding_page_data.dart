import 'package:flutter/material.dart';

/// A single pill chip shown in the animated category row above each
/// onboarding page's title. Active/inactive styling is resolved by
/// [OnboardingChipRow] itself by comparing the slot index against
/// [OnboardingPageData.activeChipIndex] — this class only carries content.
class OnboardingChipData {
  final IconData icon;
  final String label;

  const OnboardingChipData({required this.icon, required this.label});
}

/// Static content for a single onboarding page. The chip row is not
/// part of a page's own content — it's a single master strip (see
/// [OnboardingController.chips]) shared across all pages, so it isn't
/// modeled here.
///
/// [cardAlignment] is the corner/edge of the phone mockup the floating
/// card overlaps, and [cardOverlap] is how far the card is pushed past
/// that edge, as a fraction of the card's own size (consumed by
/// [FractionalTranslation] in [OnboardingMockupStack]) so it scales with
/// the card rather than a fixed pixel amount.
class OnboardingPageData {
  final String mockupAsset;
  final String cardAsset;
  final Alignment cardAlignment;
  final Offset cardOverlap;
  final double cardWidthFraction;
  final String title;
  final String subtitle;
  final String buttonLabel;

  const OnboardingPageData({
    required this.mockupAsset,
    required this.cardAsset,
    required this.cardAlignment,
    required this.cardOverlap,
    required this.cardWidthFraction,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
  });
}
