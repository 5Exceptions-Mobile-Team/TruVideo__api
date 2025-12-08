import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Widget? leading;
  const CommonAppBar({
    super.key,
    required this.title,
    this.actions,
    this.backgroundColor,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size(double.maxFinite, kToolbarHeight);
}
