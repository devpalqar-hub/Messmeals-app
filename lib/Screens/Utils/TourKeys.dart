/// GlobalKeys for the guided app tour — a single sequence that lives
/// entirely on the Home dashboard, spotlighting the buttons/icons the
/// owner needs to tap to set the app up (settings → menu → plans →
/// partners → customers → deliveries → expenses → revenue), one after
/// another, in the order they should actually do them.
library;

import 'package:flutter/widgets.dart';

class TourKeys {
  static final GlobalKey settingsGear = GlobalKey(
    debugLabel: 'tour_settings_gear',
  );
  static final GlobalKey bottomNavMenu = GlobalKey(
    debugLabel: 'tour_bottom_nav_menu',
  );
  static final GlobalKey bottomNavPlans = GlobalKey(
    debugLabel: 'tour_bottom_nav_plans',
  );
  static final GlobalKey quickActionPartner = GlobalKey(
    debugLabel: 'tour_quick_action_partner',
  );
  static final GlobalKey quickActionCustomer = GlobalKey(
    debugLabel: 'tour_quick_action_customer',
  );
  static final GlobalKey bottomNavDeliveries = GlobalKey(
    debugLabel: 'tour_bottom_nav_deliveries',
  );
  static final GlobalKey quickActionExpenses = GlobalKey(
    debugLabel: 'tour_quick_action_expenses',
  );
  static final GlobalKey revenueCard = GlobalKey(
    debugLabel: 'tour_revenue_card',
  );

  /// The full tour sequence, in the order it should be shown.
  static final List<GlobalKey> sequence = [
    settingsGear,
    bottomNavMenu,
    bottomNavPlans,
    quickActionPartner,
    quickActionCustomer,
    bottomNavDeliveries,
    quickActionExpenses,
    revenueCard,
  ];
}
