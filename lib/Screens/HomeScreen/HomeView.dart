import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mess/Screens/Customer/CustomerScreen.dart';

import 'package:mess/Screens/Utils/Bottombar.dart';

import 'package:mess/Screens/HomeScreen/HomeScreen.dart';

import 'package:mess/Screens/PartnerScreen/PartnerScreen.dart';
import 'package:mess/Screens/DeliveriesScreen/DeliveriesScreen.dart';
import 'package:mess/Screens/PlanScreen/PlanScreen.dart';

class DashboardController extends GetxController {
  var selectedIndex = 0.obs;

  final List<String> routes = [
    '/home',
    '/customers',
    '/partner',
    '/deliveries',
    '/plans',
  ];

  void changeTab(int index) {
    selectedIndex.value = index;
    Get.offNamed(routes[index], id: 1);
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController(), permanent: true);

    return Scaffold(
      backgroundColor: Colors.white,

      /// 🔥 NESTED NAVIGATION (IMPORTANT FIX)
      body: Navigator(
        key: Get.nestedKey(1),
        initialRoute: '/home',
        onGenerateRoute: (settings) {
          late Widget page;

          switch (settings.name) {
            case '/home':
              page =  HomeScreen();
              break;

            case '/customers':
              page = const CustomersScreen();
              break;

            case '/partner':
              page = const PartnerScreen();
              break;

            case '/deliveries':
              page = const DeliveriesScreen();
              break;

            case '/plans':
              page = const PlanScreen();
              break;

            default:
              page =  HomeScreen();
          }

          return GetPageRoute(
            settings: settings,
            page: () => page,
          );
        },
      ),

      /// 🔥 BOTTOM BAR
      bottomNavigationBar: Obx(() {
        return BottomBar(
          selectedIndex: controller.selectedIndex.value,
          onItemTapped: controller.changeTab,
        );
      }),
    );
  }
}