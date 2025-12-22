import 'package:flutter/material.dart';
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
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        AppButton(
          text: 'Cancel',
          onTap: () => Get.back(),
          backgroundColor: Pallet.secondaryColor,
          buttonSize: Size(context.width * 0.28, 45),
        ),
        AppButton(
          text: 'Confirm',
          onTap: onConfirm,
          backgroundColor: Pallet.secondaryColor,
          buttonSize: Size(context.width * 0.28, 45),
        ),
      ],
    );
  }
}
