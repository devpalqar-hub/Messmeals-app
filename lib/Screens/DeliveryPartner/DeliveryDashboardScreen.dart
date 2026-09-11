// DELIVERY PARTNER MODULE — DISABLED (admin-only build for now)
// Entire file commented out below; not wired into the app.
/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mess/Screens/DeliveryPartner/Customers/CustomersListScreen.dart';
import 'package:mess/Screens/DeliveryPartner/Deliveries/DeliveriesListScreen.dart';
import 'package:mess/Screens/DeliveryPartner/Deliveries/Service/PartnerDeliveryController.dart';
import 'package:mess/Screens/DeliveryPartner/Earnings/EarningsOverviewScreen.dart';
import 'package:mess/Screens/DeliveryPartner/Earnings/Service/MockEarningsController.dart';
import 'package:mess/Screens/DeliveryPartner/Home/DeliveryHomeScreen.dart';
import 'package:mess/Screens/DeliveryPartner/Profile/DeliveryProfileScreen.dart';
import 'package:mess/Screens/DeliveryPartner/Profile/Service/DeliveryProfileController.dart';
import 'package:mess/Screens/Utils/DeliveryPartnerBottomBar.dart';

/// Hosts the 5-tab delivery-partner experience — mirrors the admin
/// `DashboardScreen`/`HomeView.dart` pattern (IndexedStack-style tab switch,
/// top-level controllers registered directly here since that's the existing
/// convention rather than a route-attached `Bindings` class).
class DeliveryDashboardScreen extends StatefulWidget {
  const DeliveryDashboardScreen({super.key});

  @override
  State<DeliveryDashboardScreen> createState() => _DeliveryDashboardScreenState();
}

class _DeliveryDashboardScreenState extends State<DeliveryDashboardScreen> {
  int selectedIndex = 0;
  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    screens = [
      DeliveryHomeScreen(onNavigateToTab: onTabTapped),
      const DeliveriesListScreen(),
      const CustomersListScreen(),
      const EarningsOverviewScreen(),
      const DeliveryProfileScreen(),
    ];
  }

  void onTabTapped(int index) {
    setState(() => selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    Get.put(PartnerDeliveryController(), permanent: true);
    Get.put(DeliveryProfileController(), permanent: true);
    Get.put(MockEarningsController(), permanent: true);

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        child: DeliveryPartnerBottomBar(
          selectedIndex: selectedIndex,
          onItemTapped: onTabTapped,
        ),
      ),
      body: SafeArea(child: screens[selectedIndex]),
    );
  }
}

*/
