import 'package:flutter/material.dart';

/// Center visual for each onboarding page: a phone-mockup PNG plus one
/// smaller floating card PNG overlapping one of its edges.
///
/// Both are plain asset images with the rounded corners, teal border,
/// and drop shadow already baked into the PNGs themselves — this widget
/// only sizes and positions them, it never adds its own border, clip or
/// shadow around either.
class OnboardingMockupStack extends StatelessWidget {
  final String mockupAsset;
  final String cardAsset;
  final Alignment cardAlignment;
  final Offset cardOverlap;
  final double cardWidthFraction;

  const OnboardingMockupStack({
    super.key,
    required this.mockupAsset,
    required this.cardAsset,
    required this.cardAlignment,
    required this.cardOverlap,
    required this.cardWidthFraction,
  });

  // All onboard_*.png mockups are rendered on the same 640x1300 canvas.
  static const double _mockupAspectRatio = 640 / 1300;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double mockupWidth = screenWidth * 0.52;
    final double mockupHeight = mockupWidth / _mockupAspectRatio;
    final double cardWidth = screenWidth * cardWidthFraction;

    return SizedBox(
      width: mockupWidth,
      height: mockupHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Image.asset(mockupAsset, width: mockupWidth, fit: BoxFit.contain),
          Align(
            alignment: cardAlignment,
            child: FractionalTranslation(
              translation: cardOverlap,
              child: Image.asset(
                cardAsset,
                width: cardWidth,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
