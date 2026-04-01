import 'package:flutter/material.dart';

/// Centralized color system for Thrifty.
///
/// Designed with a minimalist, AMOLED-friendly aesthetic.
/// Follows Material 3 color system patterns.
abstract class AppColors {
  // Core Colors
  static const Color primary = Color(0xFF2E5BFF); // Neon Dark Blue
  static const Color accent = Color(0xFF00D1FF); // Secondary accent for depth

  // Dark Theme (AMOLED)
  static const Color darkBackground = Color(0xFF000000); // Pure Black
  static const Color darkSurface = Color(0xFF121212); // Near Black Surface
  static const Color darkCard = Color(0xFF1E1E1E); // Dark Card Component
  static const Color darkBorder = Color(0xFF1F1F1F); // Subtle Dark Border
  static const Color darkDivider = Color(0xFF1F1F1F);

  // Light Theme
  static const Color lightBackground = Color(0xFFFFFFFF); // Pure White
  static const Color lightSurface = Color(0xFFFBFBFB); // Off-white Surface
  static const Color lightCard = Color(0xFFFFFFFF); // White Card
  static const Color lightBorder = Color(0xFFF0F0F0); // Subtle Gray Border
  static const Color lightDivider = Color(0xFFE5E5E5);

  // Semantic Colors
  static const Color success = Color(0xFF00C853); // Vibrant Green
  static const Color error = Color(0xFFFF3B30); // Vitality Red
  static const Color warning = Color(0xFFFFCC00); // Amber Warning
  static const Color info = Color(0xFF007AFF); // Info Blue
  static const Color disabled = Color(
    0xFF3A3A3C,
  ); // Slate for dark, will adjust for light

  // Neutral Grays (Subtle, non-washed out)
  static const Color grey100 = Color(0xFFF2F2F7);
  static const Color grey200 = Color(0xFFE5E5EA);
  static const Color grey300 = Color(0xFFD1D1D6);
  static const Color grey400 = Color(0xFFC7C7CC);
  static const Color grey500 = Color(0xFF8E8E93);
  static const Color grey600 = Color(0xFF636366);
  static const Color grey700 = Color(0xFF48484A);
  static const Color grey800 = Color(0xFF2C2C2E);
  static const Color grey900 = Color(0xFF1C1C1E);

  // Glassmorphic Shadows/Blurs
  static const Color glassBlur = Color(0x33000000);
  static const Color lightGlassBlur = Color(0x1A000000);
}
