/// GlobalKeys for the guided app tours.
///
/// Three groups:
///  * the Home tour — one sequence on the Home dashboard that points at
///    every feature once ([sequence]);
///  * "prompt" keys — the follow-up "Tap here to learn X" stop for each
///    feature, shown after the Home tour and after each walkthrough;
///  * per-feature walkthrough keys — the stops inside each feature's screen.
library;

import 'package:flutter/widgets.dart';

GlobalKey _k(String label) => GlobalKey(debugLabel: 'tour_$label');

class TourKeys {
  // ---- Home tour ----
  static final GlobalKey settingsGear = _k('settings_gear');
  static final GlobalKey bottomNavMenu = _k('bottom_nav_menu');
  static final GlobalKey bottomNavPlans = _k('bottom_nav_plans');
  static final GlobalKey quickActionPartner = _k('quick_action_partner');
  static final GlobalKey quickActionCustomer = _k('quick_action_customer');
  static final GlobalKey bottomNavDeliveries = _k('bottom_nav_deliveries');
  static final GlobalKey quickActionExpenses = _k('quick_action_expenses');
  static final GlobalKey revenueCard = _k('revenue_card');

  /// The full Home tour sequence, in the order it should be shown.
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

  // ---- Prompts ("Tap here to learn X") ----
  // Nav-bar prompts sit on each tab icon, so they work from any tab.
  static final GlobalKey promptMenu = _k('prompt_menu');
  static final GlobalKey promptPlans = _k('prompt_plans');
  static final GlobalKey promptPartners = _k('prompt_partners');
  static final GlobalKey promptCustomers = _k('prompt_customers');
  static final GlobalKey promptDeliveries = _k('prompt_deliveries');
  // These two live on the Home dashboard itself.
  static final GlobalKey promptExpenses = _k('prompt_expenses');
  static final GlobalKey promptSettings = _k('prompt_settings');

  /// The prompt key for a feature walkthrough id (see AppTourController).
  static GlobalKey promptFor(String tourId) => switch (tourId) {
    'menu' => promptMenu,
    'plans' => promptPlans,
    'partners' => promptPartners,
    'customers' => promptCustomers,
    'deliveries' => promptDeliveries,
    'expenses' => promptExpenses,
    _ => promptSettings,
  };

  // ---- Menu walkthrough ----
  static final GlobalKey menuAddButton = _k('menu_add');
  static final GlobalKey menuShare = _k('menu_share');
  static final GlobalKey menuEdit = _k('menu_edit');
  static final GlobalKey menuDelete = _k('menu_delete');

  // ---- Plans walkthrough ----
  static final GlobalKey plansAdd = _k('plans_add');
  static final GlobalKey plansEdit = _k('plans_edit');
  static final GlobalKey plansDelete = _k('plans_delete');

  // ---- Partners walkthrough ----
  static final GlobalKey partnersAdd = _k('partners_add');
  static final GlobalKey partnersEdit = _k('partners_edit');
  static final GlobalKey partnersDelete = _k('partners_delete');
  static final GlobalKey partnersDetails = _k('partners_details');

  // ---- Customers walkthrough ----
  static final GlobalKey customersAdd = _k('customers_add');
  static final GlobalKey customersSearch = _k('customers_search');
  static final GlobalKey customersCard = _k('customers_card');

  // ---- Deliveries walkthrough ----
  static final GlobalKey deliveriesSummary = _k('deliveries_summary');
  static final GlobalKey deliveriesFilters = _k('deliveries_filters');
  static final GlobalKey deliveriesCard = _k('deliveries_card');

  // ---- Expenses walkthrough ----
  static final GlobalKey expensesAddCategory = _k('expenses_add_category');
  static final GlobalKey expensesAddExpense = _k('expenses_add_expense');

  // ---- Mess profile (settings) walkthrough ----
  static final GlobalKey settingsBasicInfo = _k('settings_basic_info');
  static final GlobalKey settingsCover = _k('settings_cover');
  static final GlobalKey settingsSave = _k('settings_save');
}
