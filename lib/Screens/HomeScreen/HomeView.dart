import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mess/Screens/Customer/CustomerScreen.dart';
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
import 'package:mess/Screens/Utils/AppTourController.dart';
import 'package:mess/Screens/Utils/Bottombar.dart';
import 'package:mess/Screens/HomeScreen/HomeScreen.dart';
import 'package:mess/Screens/PartnerScreen/PartnerScreen.dart';
import 'package:mess/Screens/DeliveriesScreen/DeliveriesScreen.dart';
import 'package:mess/Screens/PlanScreen/PlanScreen.dart';
import 'package:mess/Screens/MenuScreen/MenuScreen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();

    // Lets the guided tour bring the owner back to the Home tab.
    AppTourController.instance.selectTab = onTabTapped;

    screens = [
      Homescreen(onNavigateToTab: onTabTapped),
      CustomersScreen(),
      PartnerScreen(),
      DeliveriesScreen(),
      PlanScreen(),
      MenuScreen(),
    ];
  }

  void onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    // BUG #3193 — the Home tab's widget is built once and kept alive, so
    // revenue/stats never re-fetched on their own when coming back to it
    // from another tab (previously only happened on a full app restart).
    if (index == 0) {
      Get.find<HomeScreenController>().refreshAllData();
    }
  }

  @override
  Widget build(BuildContext context) {
    Get.put(HomeScreenController(), permanent: true);

    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: SafeArea(
        child: BottomBar(
          selectedIndex: selectedIndex,
          onItemTapped: onTabTapped,
        ),
      ),

      body: SafeArea(child: screens[selectedIndex]),
    );
  }
}
