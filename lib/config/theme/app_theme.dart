import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';

class AppTheme {
  static InputBorder _border([Color color = Pallet.glassBorder]) =>
      OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      );

  static final ThemeData darkTheme = ThemeData.light().copyWith(
    // We use light base but name it darkTheme in code to replace existing usage seamlessly
    // or we can rename it. Let's stick to modifying the existing static (or rename variable to lightTheme but keep it assigned where needed)
    // Actually, user won't change main.dart likely, so I'll keep the variable name consistent or update main.dart.
    // Let's check main.dart usage. It uses AppTheme.darkTheme. I will update main.dart too if I rename it.
    // For now, I'll return the new theme in the existing variable or create a new one.
    // The previous plan didn't mention updating main.dart, but it's cleaner to just update the content of this variable to be "Light Mode"
    scaffoldBackgroundColor:
        Colors.transparent, // Important for GradientBackground
    primaryColor: Pallet.primaryColor,
    colorScheme: const ColorScheme.light(
      primary: Pallet.primaryColor,
      secondary: Pallet.secondaryColor,
      surface: Pallet.glassWhite, // Glassy surface
      error: Pallet.errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Pallet.textMain,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent, // Full transparency
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Pallet.textMain),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Pallet.textMain,
      ),
    ),
    cardTheme: CardThemeData(
      color: Pallet.glassWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: Pallet.glassBorder,
      thickness: 1,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Pallet.primaryColor,
    ),
    iconTheme: const IconThemeData(color: Pallet.textSecondary),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      filled: true,
      fillColor: Pallet.glassWhite,
      border: _border(),
      enabledBorder: _border(Colors.grey),
      focusedBorder: _border(Pallet.primaryColor),
      errorBorder: _border(Pallet.errorColor),
      hintStyle: GoogleFonts.inter(color: Pallet.greyColor),
      labelStyle: GoogleFonts.inter(color: Pallet.greyColor),
    ),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.light().textTheme,
    ).apply(bodyColor: Pallet.textMain, displayColor: Pallet.textMain),
    // Switch to light theme text colors
  );
}
