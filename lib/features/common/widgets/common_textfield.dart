import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommonTextField extends StatelessWidget {
  final String hintText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int? maxLines;
  final int? maxLength;
  final bool? isObscure;
  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const CommonTextField({
    super.key,
    required this.hintText,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines,
    this.maxLength,
    this.isObscure,
    this.textInputType,
    this.textInputAction,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: isObscure ?? false,
      keyboardType: textInputType,
      maxLines: maxLines ?? 1,
      maxLength: maxLength,
      style: GoogleFonts.inter(fontSize: 15),
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      textInputAction: textInputAction,
      decoration: InputDecoration(
        // contentPadding is handled by Theme, but can be overridden here if needed
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        hintText: hintText,
        // Remove hardcoded hintStyle color to respect Theme (which uses Pallet.greyColor)
        hintStyle: GoogleFonts.inter(fontSize: 14),
      ),
    );
  }
}
