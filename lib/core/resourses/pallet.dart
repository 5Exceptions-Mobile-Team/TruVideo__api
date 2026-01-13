import 'package:flutter/material.dart';

class Pallet {
  // Gradient Colors (Soft, dreamy mesh gradient)
  static const Color gradient1 = Color(0xFFF3E8FF); // Soft Purple
  static const Color gradient2 = Color(0xFFE0F2FE); // Soft Blue
  static const Color gradient3 = Color(0xFFFCE7F3); // Soft Pink

  // Primary Brand Colors (Vibrant for contrast)
  static const Color primaryColor = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryDarkColor = Color(0xFF4338CA); // Indigo 700
  static const Color primaryLightColor = Color(0xFF818CF8); // Indigo 400

  // Secondary/Accent Colors
  static const Color secondaryColor = Color(0xFF0EA5E9); // Sky 500
  static const Color secondaryDarkColor = Color(0xFF0284C7); // Sky 600
  static const Color tertiaryColor = Color(0xFFEC4899); // Pink 500

  // Glass/Frost Colors
  static const Color glassWhite = Color(0x66FFFFFF); // 40% White
  static const Color glassWhiteHigh = Color(0xCCFFFFFF); // 80% White
  static const Color glassBorder = Color(0x33FFFFFF); // 20% White

  // Text Colors (High Contrast for Light Mode)
  static const Color textMain = Color(0xFF1E293B); // Slate 800
  static const Color textPrimary = textMain; // Alias for textMain
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color whiteColor = Colors.white;
  static const Color greyColor = Color(0xFF94A3B8); // Slate 400

  // Glass/Frost Colors (Additional)
  static const Color glassWhiteLow = Color(0x33FFFFFF); // 20% White

  // Functional
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF22C55E);

  // Backgrounds (Fallback)
  static const Color backgroundColor = Color(0xFFF8FAFC); // Slate 50
  static const Color secondaryBackground = Color(0xFFF1F5F9); // Slate 100
}
