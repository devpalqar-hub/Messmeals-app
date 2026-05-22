import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess/Screens/CustomerScreen/CustomerScreen.dart';
import 'package:mess/Screens/DeliveriesScreen/DeliveriesScreen.dart';
import 'package:mess/Screens/HomeScreen/HomeScreen.dart';
import 'package:mess/Screens/PartnerScreen/PartnerScreen.dart';
import 'package:mess/Screens/PlanScreen/PlanScreen.dart';
import 'package:mess/Screens/Utils/Bottombar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  final List<Widget> screens = [
    Homescreen(),
    CustomersScreen(),
    PartnerScreen(),
    DeliveriesScreen(),
    PlanScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
