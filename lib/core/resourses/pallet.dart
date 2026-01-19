import 'package:flutter/material.dart';

class Pallet {
  // Gradient Colors (Neutral professional blues and grays)
  static const Color gradient1 = Color(0xFFF8FAFC); // Very light gray-blue
  static const Color gradient2 = Color(0xFFF1F5F9); // Light gray-blue
  static const Color gradient3 = Color(0xFFE2E8F0); // Medium light gray-blue

  // Primary Brand Colors (Professional blue tones)
  static const Color primaryColor = Color(0xFF2563EB); // Blue 600
  static const Color primaryDarkColor = Color(0xFF1D4ED8); // Blue 700
  static const Color primaryLightColor = Color(0xFF3B82F6); // Blue 500

  // Secondary/Accent Colors
  static const Color secondaryColor = Color(0xFF475569); // Slate 600
  static const Color secondaryDarkColor = Color(0xFF334155); // Slate 700
  static const Color tertiaryColor = Color(0xFF64748B); // Slate 500

  // Glass/Frost Colors (Neutral, minimal)
  static const Color glassWhite = Color(0xE6FFFFFF); // 90% White for cards
  static const Color glassWhiteHigh = Color(0xF5FFFFFF); // 96% White
  static const Color glassBorder = Color(0x1A000000); // 10% Black border
  static const Color glassWhiteLow = Color(
    0x80000000,
  ); // 50% Black for subtle backgrounds

  // Text Colors (High Contrast for Light Mode)
  static const Color textMain = Color(0xFF0F172A); // Slate 900
  static const Color textPrimary = textMain; // Alias for textMain
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textBlack = Colors.black;
  static const Color whiteColor = Colors.white;
  static const Color greyColor = Color(0xFF94A3B8); // Slate 400

  // Card and Surface Colors (with light tints)
  static const Color cardBackground = Color(
    0xFFFAFBFC,
  ); // Very light blue-gray tint
  static const Color cardBackgroundSubtle = Color(
    0xFFF5F7FA,
  ); // Light blue-gray
  static const Color cardBackgroundAlt = Color(
    0xFFF8F9FB,
  ); // Alternative light tint
  static const Color surfaceColor = Color(0xFFF1F5F9); // Slate 100

  // Functional
  static const Color errorColor = Color(0xFFDC2626); // Red 600
  static const Color successColor = Color(0xFF16A34A); // Green 600
  static const Color warningColor = Color(0xFFD97706); // Amber 600

  // Backgrounds
  static const Color backgroundColor = Color(0xFFF8FAFC); // Slate 50
  static const Color secondaryBackground = Color(0xFFF1F5F9); // Slate 100
}
