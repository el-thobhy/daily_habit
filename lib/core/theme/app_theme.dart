import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  // Habit Colors Palette
  static const List<Color> habitColors = [
    Color(0xFF3B82F6), // Blue
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Violet
    Color(0xFF14B8A6), // Teal
    Color(0xFFF97316), // Orange
    Color(0xFF06B6D4), // Cyan
  ];
  // Typography
  static TextTheme get textTheme => const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary,
    ),
    displayMedium: TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16, fontWeight: FontWeight.normal, color: textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14, fontWeight: FontWeight.normal, color: textSecondary,
    ),
  );
   // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}