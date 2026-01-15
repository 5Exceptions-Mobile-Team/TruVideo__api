import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';

class AppTheme {
  static InputBorder _border([Color? color]) =>
      OutlineInputBorder(
        borderSide: BorderSide(
          color: color ?? Pallet.glassBorder,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      );

  static final ThemeData darkTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor:
        Colors.transparent, // Important for GradientBackground
    primaryColor: Pallet.primaryColor,
    colorScheme: const ColorScheme.light(
      primary: Pallet.primaryColor,
      secondary: Pallet.secondaryColor,
      surface: Pallet.cardBackground,
      error: Pallet.errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Pallet.textMain,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Pallet.textMain),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Pallet.textMain,
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: Pallet.cardBackground,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Pallet.glassBorder,
          width: 1,
        ),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: DividerThemeData(
      color: Pallet.glassBorder,
      thickness: 1,
      space: 1,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Pallet.primaryColor,
    ),
    iconTheme: const IconThemeData(color: Pallet.textSecondary),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      filled: true,
      fillColor: Pallet.cardBackground,
      border: _border(),
      enabledBorder: _border(Pallet.glassBorder),
      focusedBorder: _border(Pallet.primaryColor),
      errorBorder: _border(Pallet.errorColor),
      hintStyle: GoogleFonts.inter(
        color: Pallet.greyColor,
        fontSize: 15,
      ),
      labelStyle: GoogleFonts.inter(
        color: Pallet.textSecondary,
        fontSize: 14,
      ),
    ),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.light().textTheme,
    ).apply(
      bodyColor: Pallet.textMain,
      displayColor: Pallet.textMain,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Pallet.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Pallet.primaryColor.withOpacity(0.2),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Pallet.primaryColor,
        side: BorderSide(color: Pallet.primaryColor, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
