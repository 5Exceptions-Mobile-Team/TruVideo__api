import 'package:flutter/material.dart';

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
      // style: TextStyle(fontSize: 12),
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      textInputAction: textInputAction,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 25,
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
        counterStyle: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}
