import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home_outlined, 'label': 'Home'},
      {'icon': Icons.group_outlined, 'label': 'Customers'},
      {'icon': Icons.local_shipping_outlined, 'label': 'Partners'},
      {'icon': Icons.inventory_2_outlined, 'label': 'Deliveries'},
      {'icon': Icons.assignment_outlined, 'label': 'Plans'},
      {'icon': Icons.restaurant_menu_outlined, 'label': 'Menu'},
    ];

    return Container(
      height: 60, // ✅ FIX 1 → fixed slim height
      decoration: const BoxDecoration(
        // color: Color(0xFF1C1F2E),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onItemTapped(index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // ✅ center items
              children: [
                Icon(
                  item['icon'] as IconData,
                  color: isSelected ? Color(0xFF7ED321) : Colors.grey,
                  size: 20, // ✅ FIX 2 → smaller icon
                ),
                const SizedBox(height: 2), // ✅ less gap
                Text(
                  item['label'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500, // ✅ FIX 3 → smaller text
                    color: isSelected ? Color(0xFF7ED321) : Colors.grey,
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
