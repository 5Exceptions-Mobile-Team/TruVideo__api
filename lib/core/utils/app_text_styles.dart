import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';

/// Common text styles for descriptive/explanation text throughout the app.
/// All styles use black color (Pallet.textPrimary) instead of grey.
class AppTextStyles {
  AppTextStyles._(); // Private constructor to prevent instantiation

  /// Extra small body text - fontSize 11
  /// Used for very small descriptive text, helper text, tooltips
  static TextStyle bodyExtraSmall({double? height, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      fontSize: 11,
      color: Pallet.textBlack,
      height: height,
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }

  /// Small body text - fontSize 12
  /// Used for small descriptive text, captions, helper text
  static TextStyle bodySmall({double? height, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      fontSize: 12,
      color: Pallet.textBlack,
      height: height,
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }

  /// Medium body text - fontSize 13
  /// Used for standard descriptive text, explanations
  static TextStyle bodyMedium({double? height, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      fontSize: 13,
      color: Pallet.textBlack,
      height: height,
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }

  /// Large body text - fontSize 14
  /// Used for larger descriptive text, detailed explanations
  static TextStyle bodyLarge({double? height, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      fontSize: 14,
      color: Pallet.textBlack,
      height: height,
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }

  /// Extra large body text - fontSize 15
  /// Used for prominent descriptive text, main explanations
  static TextStyle bodyXLarge({double? height, FontWeight? fontWeight}) {
    return GoogleFonts.inter(
      fontSize: 15,
      color: Pallet.textBlack,
      height: height,
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }
}
