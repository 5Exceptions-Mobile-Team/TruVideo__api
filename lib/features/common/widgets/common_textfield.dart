import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';

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
  final Key? valueKey;

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
    this.valueKey,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: valueKey,
      controller: controller,
      onChanged: onChanged,
      obscureText: isObscure ?? false,
      keyboardType: textInputType,
      maxLines: maxLines ?? 1,
      maxLength: maxLength,
      style: GoogleFonts.inter(fontSize: 15, color: Pallet.textPrimary),
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      textInputAction: textInputAction,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: GoogleFonts.inter(fontSize: 15, color: Pallet.greyColor),
      ),
    );
  }
}
