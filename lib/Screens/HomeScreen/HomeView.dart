
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

  // 🔹 Add more screens later if you have multiple tabs
  final List<Widget> screens = [
    HomeScreen(),
    CustomersScreen(),
    PartnerScreen(),
    DeliveriesScreen(),
    PlanScreen(),
    // Add more: CustomersScreen(), PartnersScreen(), etc.
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
      body: SafeArea(
        child: Stack(
          children: [
            /// 🔹 Main screen content (changes with tab)
            Positioned.fill(
              child: screens[selectedIndex],
            ),

            /// 🔹 BottomBar widget pinned to bottom
            Positioned(
              left: 0,
              right: 0,
             bottom: 0.1, // space above screen edge
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BottomBar(
                      selectedIndex: selectedIndex,
                      onItemTapped: onTabTapped,
                    ),
                    const SizedBox(height: 20), // extra padding below
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
