import 'package:flutter/material.dart';

class CameraModeField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final Key? valueKey;
  const CameraModeField({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.valueKey,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: valueKey,
      style: TextStyle(fontSize: 12),
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 25,
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey[700] ?? Colors.grey,
          fontSize: 15,
        ),
        counterStyle: TextStyle(fontSize: 12, color: Colors.grey),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[900] ?? Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
