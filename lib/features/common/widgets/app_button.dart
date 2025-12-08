import 'package:flutter/material.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Size? buttonSize;
  final Icon? buttonIcon;
  final double? fontSize;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? fontColor;
  final bool showLoading;
  const AppButton({
    super.key,
    required this.text,
    required this.onTap,
    this.buttonSize,
    this.buttonIcon,
    this.fontSize,
    this.borderRadius,
    this.backgroundColor,
    this.fontColor,
    this.showLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        fixedSize: buttonSize ?? Size(double.maxFinite, 45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 15),
        ),
        backgroundColor: backgroundColor ?? Pallet.secondaryBackground,
      ),
      child: showLoading
          ? CircularProgressIndicator.adaptive()
          : buttonIcon == null
          ? Text(
              text,
              style: TextStyle(
                color: fontColor ?? Colors.white,
                fontSize: fontSize ?? 14,
              ),
            )
          : Row(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buttonIcon ?? const SizedBox(),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize ?? 14,
                    color: fontColor ?? Colors.white,
                  ),
                ),
              ],
            ),
    );
  }
}
