import 'package:get/get.dart';
import 'package:mess/Screens/Customer/AddCustomerScreen.dart';
import 'package:mess/Screens/Customer/CustomerScreen.dart';

import 'package:mess/Screens/HomeScreen/HomeView.dart';
import 'package:mess/Screens/LoginScreen/LoginScreen.dart';
import 'package:mess/Screens/PartnerScreen/PartnerScreen.dart';
import 'package:mess/Screens/DeliveriesScreen/DeliveriesScreen.dart';
import 'package:mess/Screens/PlanScreen/PlanScreen.dart';
import 'package:mess/Screens/MenuScreen/MenuScreen.dart';
import 'package:mess/Screens/ExpenseScreen/ExpenseScreen.dart';
import 'package:mess/Screens/OnboardingScreen/onboarding_screen.dart';
import 'package:mess/Screens/SplashScreen/SplashScreen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const Customer = '/customers';
  static const partners = '/partners';
  static const deliveries = '/deliveries';
  static const plans = '/plans';
  static const menus = '/menus';
  static const expenses = '/expenses';

  // ✅ THIS is what you are missing / misnamed
  static final List<GetPage> routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: onboarding, page: () => OnboardingScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: dashboard, page: () => DashboardScreen()),
    GetPage(name: Customer, page: () => CustomersScreen()),
    GetPage(name: partners, page: () => PartnerScreen()),
    GetPage(name: deliveries, page: () => DeliveriesScreen()),
    GetPage(name: plans, page: () => PlanScreen()),
    GetPage(name: menus, page: () => const MenuScreen()),
    GetPage(name: expenses, page: () => const ExpenseScreen()),
  ];
}
