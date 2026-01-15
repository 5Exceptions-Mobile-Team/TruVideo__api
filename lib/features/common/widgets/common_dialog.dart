import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/common/widgets/app_button.dart';

class CommonDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;
  const CommonDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    // Optimize dialog size for desktop/web
    final isDesktop = MediaQuery.of(context).size.width >= 768 || kIsWeb;
    final dialogWidth = isDesktop ? 500.0 : null;
    
    return AlertDialog(
      backgroundColor: Pallet.gradient2,
      title: Text(title),
      content: SizedBox(
        width: dialogWidth,
        child: Text(content),
      ),
      actions: [
        AppButton(
          text: 'Cancel',
          onTap: () => Get.back(),
          backgroundColor: Pallet.secondaryColor,
          buttonSize: Size(isDesktop ? 120 : context.width * 0.28, 45),
        ),
        AppButton(
          text: 'Confirm',
          onTap: onConfirm,
          backgroundColor: Pallet.secondaryColor,
          buttonSize: Size(isDesktop ? 120 : context.width * 0.28, 45),
        ),
      ],
    );
  }
}
