import 'package:flutter/material.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';

class AppTheme {
  static InputBorder _border([Color color = Colors.grey]) => OutlineInputBorder(
    borderSide: BorderSide(color: color),
    borderRadius: BorderRadius.circular(15),
  );
  static final ThemeData darkTheme = ThemeData.light().copyWith(
    // scaffoldBackgroundColor: Pallet.backgroundColor,
    appBarTheme: const AppBarTheme(backgroundColor: Pallet.backgroundColor),
    cardTheme: const CardThemeData(color: Pallet.secondaryBackground),
    dividerTheme: DividerThemeData(color: Colors.grey[600]),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Colors.white,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      border: _border(),
      enabledBorder: _border(),
      focusedBorder: _border(Pallet.tertiaryColor),
      errorBorder: _border(Pallet.errorColor),
    ),
  );
}
