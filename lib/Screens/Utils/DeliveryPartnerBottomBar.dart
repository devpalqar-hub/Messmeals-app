// DELIVERY PARTNER MODULE — DISABLED (admin-only build for now)
// Entire file commented out below; not wired into the app.
/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess/Screens/Utils/AppColors.dart';

class DeliveryPartnerBottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const DeliveryPartnerBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home_outlined, 'label': 'Home'},
      {'icon': Icons.local_shipping_outlined, 'label': 'Deliveries'},
      {'icon': Icons.group_outlined, 'label': 'Customers'},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'Earnings'},
      {'icon': Icons.person_outline, 'label': 'Profile'},
    ];

    return Container(
      height: 60,
      decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onItemTapped(index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item['icon'] as IconData,
                  color: isSelected ? AppColors.primary : Colors.grey,
                  size: 20,
                ),
                const SizedBox(height: 2),
                Text(
                  item['label'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppColors.primary : Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

*/
