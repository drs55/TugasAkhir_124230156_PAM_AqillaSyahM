// ============================================================================
// 🎨 APP COLORS - Konstanta warna aplikasi
// ============================================================================

import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF2193b0);
  static const Color secondary = Color(0xFF6dd5ed);
  
  // Gradient Colors
  static const Color gradientStart = Color(0xFF2193b0);
  static const Color gradientEnd = Color(0xFF6dd5ed);
  
  // Text Colors
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color textWhite = Colors.white;
  
  // Background Colors
  static const Color background = Colors.white;
  static const Color backgroundLight = Color(0xFFF5F5F5);
  
  // Status Colors
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color warning = Colors.orange;
  static const Color info = Colors.blue;
  
  // Card Colors
  static const Color cardBackground = Colors.white;
  static const Color cardShadow = Colors.black12;
  
  // Border Colors
  static const Color border = Colors.grey;
  static const Color borderLight = Color(0xFFE0E0E0);
  
  // Gradient untuk Background
  static LinearGradient get primaryGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );
  
  // Gradient untuk Button
  static LinearGradient get buttonGradient => const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, secondary],
  );
}
