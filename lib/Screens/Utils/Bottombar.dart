import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mess/Screens/Utils/TiffinBoxIcon.dart';

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
      {
        'icon': (Color c, double s) => Icon(Icons.home_outlined, color: c, size: s),
        'label': 'Home',
      },
      {
        'icon': (Color c, double s) => Icon(Icons.group_outlined, color: c, size: s),
        'label': 'Customers',
      },
      {
        'icon':
            (Color c, double s) =>
                Icon(Icons.delivery_dining_outlined, color: c, size: s),
        'label': 'Partners',
      },
      {
        'icon': (Color c, double s) => TiffinBoxIcon(color: c, size: s),
        'label': 'Deliveries',
      },
      {
        'icon': (Color c, double s) => Icon(Icons.assignment_outlined, color: c, size: s),
        'label': 'Plans',
      },
      {
        'icon':
            (Color c, double s) =>
                Icon(Icons.restaurant_menu_outlined, color: c, size: s),
        'label': 'Menu',
      },
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
                (item['icon'] as Widget Function(Color, double))(
                  isSelected ? const Color(0xFF7ED321) : Colors.grey,
                  20, // ✅ FIX 2 → smaller icon
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
