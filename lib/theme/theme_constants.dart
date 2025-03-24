import 'package:flutter/material.dart';

class ThemeConstants {
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Border Radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;

  // Elevation
  static const double elevationS = 1.0;
  static const double elevationM = 2.0;
  static const double elevationL = 4.0;
  static const double elevationXL = 8.0;

  // Light Theme Colors
  static const Color lightPrimary = Color(0xFF2196F3);
  static const Color lightSecondary = Color(0xFF4CAF50);
  static const Color lightTertiary = Color(0xFFFF9800);
  static const Color lightError = Color(0xFFE53935);
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Colors.white;
  static const Color lightOnSurface = Colors.black87;

  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFF64B5F6);
  static const Color darkSecondary = Color(0xFF81C784);
  static const Color darkTertiary = Color(0xFFFFB74D);
  static const Color darkError = Color(0xFFE57373);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnSurface = Colors.white70;

  // Text Styles
  static const TextStyle displayLarge = TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
  static const TextStyle displayMedium = TextStyle(fontSize: 28, fontWeight: FontWeight.bold);
  static const TextStyle displaySmall = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  static const TextStyle headlineMedium = TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
  static const TextStyle titleLarge = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  static const TextStyle bodyLarge = TextStyle(fontSize: 16);
  static const TextStyle bodyMedium = TextStyle(fontSize: 14);
}