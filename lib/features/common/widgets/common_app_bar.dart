import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Widget? leading;
  final bool centerTitle;

  const CommonAppBar({
    super.key,
    required this.title,
    this.actions,
    this.backgroundColor,
    this.leading,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: Text(
        title,
        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      centerTitle: centerTitle,
      actions: actions,
      backgroundColor: backgroundColor, // Will default to theme if null
      surfaceTintColor: Colors.transparent, // Avoid tint on scroll
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
