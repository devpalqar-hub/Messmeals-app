import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess/Screens/Utils/TiffinBoxIcon.dart';
import 'package:mess/Screens/Utils/AppTourController.dart';
import 'package:mess/Screens/Utils/TourStop.dart';
import 'package:mess/Screens/Utils/TourKeys.dart';
import 'package:mess/Screens/Utils/TourTooltipActions.dart';
import 'package:showcaseview/showcaseview.dart';

class BottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'icon':
            (Color c, double s) => Icon(Icons.home_outlined, color: c, size: s),
        'label': 'Home',
      },
      {
        'icon':
            (Color c, double s) =>
                Icon(Icons.group_outlined, color: c, size: s),
        'label': 'Customers',
      },
      {
        'icon':
            (Color c, double s) =>
                Icon(Icons.delivery_dining_outlined, color: c, size: s),
        'label': 'Partners',
      },
      {
        'icon': (Color c, double s) => TiffinBoxIcon(color: c, size: s),
        'label': 'Deliveries',
      },
      {
        'icon':
            (Color c, double s) =>
                Icon(Icons.assignment_outlined, color: c, size: s),
        'label': 'Plans',
      },
      {
        'icon':
            (Color c, double s) =>
                Icon(Icons.restaurant_menu_outlined, color: c, size: s),
        'label': 'Menu',
      },
    ];

    // The Home tour spotlights the Menu, Plans and Deliveries tabs
    // individually (steps 2, 3 and 6 of 8).
    const tourStepForIndex = {5: 2, 4: 3, 3: 6};
    final tourKeyForIndex = {
      5: TourKeys.bottomNavMenu,
      4: TourKeys.bottomNavPlans,
      3: TourKeys.bottomNavDeliveries,
    };

    // Every feature tab also carries a "Tap here to learn …" prompt, shown
    // after the Home tour and after each previous feature walkthrough;
    // tapping it opens the tab and starts that feature's walkthrough.
    const promptTourForIndex = {
      5: AppTourController.menuTour,
      4: AppTourController.plansTour,
      2: AppTourController.partnersTour,
      1: AppTourController.customersTour,
      3: AppTourController.deliveriesTour,
    };
    const promptTextForTour = {
      AppTourController.menuTour: (
        'Tap here to learn how to use Menu',
        'We\'ll show you how to create, share, edit and delete a menu.',
      ),
      AppTourController.plansTour: (
        'Tap here to learn how to use Plans',
        'We\'ll show you how to create, edit and delete a plan.',
      ),
      AppTourController.partnersTour: (
        'Tap here to learn Delivery Partners',
        'We\'ll show you how to add, edit and delete a partner.',
      ),
      AppTourController.customersTour: (
        'Tap here to learn how to use Customers',
        'We\'ll show you how to add a customer, find one, and open their details.',
      ),
      AppTourController.deliveriesTour: (
        'Tap here to learn how to use Deliveries',
        'We\'ll show you how to read today\'s deliveries and update them.',
      ),
    };

    return Container(
      height: 60, // ✅ FIX 1 → fixed slim height
      decoration: const BoxDecoration(
        // color: Color(0xFF1C1F2E),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = index == selectedIndex;

          final navItem = GestureDetector(
            onTap: () => onItemTapped(index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // ✅ center items
              children: [
                (item['icon'] as Widget Function(Color, double))(
                  isSelected ? const Color(0xFF7ED321) : Colors.grey,
                  20, // ✅ FIX 2 → smaller icon
                ),
                const SizedBox(height: 2), // ✅ less gap
                Text(
                  item['label'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500, // ✅ FIX 3 → smaller text
                    color: isSelected ? Color(0xFF7ED321) : Colors.grey,
                  ),
                ),
              ],
            ),
          );

          final promptTour = promptTourForIndex[index];
          final tappable =
              promptTour == null
                  ? navItem
                  : tourPrompt(
                    key: TourKeys.promptFor(promptTour),
                    tourId: promptTour,
                    title: promptTextForTour[promptTour]!.$1,
                    description: promptTextForTour[promptTour]!.$2,
                    onOpen: () => onItemTapped(index),
                    child: navItem,
                  );

          final tourStep = tourStepForIndex[index];
          if (tourStep == null) return tappable;

          return Showcase(
            key: tourKeyForIndex[index]!,
            title: switch (item['label']) {
              'Menu' => 'Tap here to manage your Menu',
              'Plans' => 'Tap here to manage your Plans',
              _ => 'Tap here to track Deliveries',
            },
            description: switch (item['label']) {
              'Menu' => 'Build your weekly menu — what\'s served each day.',
              'Plans' =>
                'Create a subscription plan — set the price and schedule.',
              _ => 'Track today\'s deliveries and mark orders as delivered.',
            },
            titleTextStyle: tourTitleStyle(),
            descTextStyle: tourDescStyle(),
            descriptionPadding: tourDescPadding(),
            tooltipBorderRadius: tourTooltipBorderRadius(),
            tooltipPadding: tourTooltipPadding(),
            targetBorderRadius: tourTargetBorderRadius(),
            targetPadding: tourTargetPadding(),
            overlayColor: tourOverlayColor(),
            overlayOpacity: tourOverlayOpacity(),
            blurValue: tourBlurValue(),
            scaleAnimationDuration: tourScaleAnimationDuration(),
            scaleAnimationCurve: tourScaleAnimationCurve(),
            movingAnimationDuration: tourMovingAnimationDuration(),
            tooltipActionConfig: const TooltipActionConfig(
              alignment: MainAxisAlignment.spaceBetween,
            ),
            tooltipActions: tourTooltipActions(
              context,
              step: tourStep,
              total: TourKeys.sequence.length,
            ),
            child: tappable,
          );
        }),
      ),
    );
  }
}
