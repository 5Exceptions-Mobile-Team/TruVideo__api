import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';

class AppButton extends StatefulWidget {
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
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? Pallet.primaryColor;
    
    return GestureDetector(
          onTapDown: (_) => setState(() => isPressed = true),
          onTapUp: (_) => setState(() => isPressed = false),
          onTapCancel: () => setState(() => isPressed = false),
          onTap: widget.showLoading ? null : widget.onTap,
          child: AnimatedScale(
        scale: isPressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              width: widget.buttonSize?.width ?? double.maxFinite,
              height: widget.buttonSize?.height ?? 50,
              decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
                boxShadow: [
                  BoxShadow(
                color: bgColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: widget.showLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.buttonIcon != null) ...[
                          widget.buttonIcon!,
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: GoogleFonts.inter(
                            fontSize: widget.fontSize ?? 16,
                            fontWeight: FontWeight.w600,
                            color: widget.fontColor ?? Colors.white,
                        letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, end: 0);
  }
}
