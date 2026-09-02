import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mess/Screens/Customer/CustomerScreen.dart';
import 'package:mess/Screens/HomeScreen/Service/HomeScreenController.dart';
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

    screens = [
      Homescreen(
        onNavigateToTab: onTabTapped,
      ),
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

      body: SafeArea(
        child: screens[selectedIndex],
      ),
    );
  }
}