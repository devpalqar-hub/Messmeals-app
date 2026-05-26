import 'package:get/get.dart';
import 'package:mess/Screens/Customer/AddCustomerScreen.dart';
import 'package:mess/Screens/Customer/CustomerScreen.dart';

import 'package:mess/Screens/HomeScreen/HomeView.dart';
import 'package:mess/Screens/LoginScreen/LoginScreen.dart';
import 'package:mess/Screens/CustomerScreen/Views/AddCustomerScreen.dart';
import 'package:mess/Screens/PartnerScreen/PartnerScreen.dart';
import 'package:mess/Screens/DeliveriesScreen/DeliveriesScreen.dart';
import 'package:mess/Screens/PlanScreen/PlanScreen.dart';

class AppRoutes {
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const Customer = '/customers';
  static const partners = '/partners';
  static const deliveries = '/deliveries';
  static const plans = '/plans';

  // ✅ THIS is what you are missing / misnamed
  static final List<GetPage> routes = [
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: dashboard, page: () => DashboardScreen()),
    GetPage(name: Customer, page: () => CustomersScreen()),
    GetPage(name: partners, page: () => PartnerScreen()),
    GetPage(name: deliveries, page: () => DeliveriesScreen()),
    GetPage(name: plans, page: () => PlanScreen()),
    

  ];
}
