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
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F2E),
        borderRadius: const BorderRadius.all(
          Radius.circular(16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = index == selectedIndex;
        
            return GestureDetector(
              onTap: () => onItemTapped(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    color: isSelected ? Colors.cyanAccent : Colors.grey,
                    size: 28,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item['label'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: isSelected ? Colors.cyanAccent : Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
