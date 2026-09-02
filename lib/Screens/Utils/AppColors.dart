import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors — brand green
  static const Color primary = Color(0xFF7ED321);
  static const Color secondary = Color(0xFF8BC53F);
  // Deeper shade of the same green for gradients/headers that need more contrast on white.
  static const Color primaryDark = Color(0xFF5C9A1B);

  static const List<Color> primaryGradient = [primary, secondary];

  // Background Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color scaffold = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);

  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Border / Divider
  static const Color border = Color(0xFFE5E7EB);
}