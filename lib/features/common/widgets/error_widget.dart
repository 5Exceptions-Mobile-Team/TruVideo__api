import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/common/widgets/glass_container.dart';

import 'app_button.dart';

class ErrorDialog extends StatelessWidget {
  final String? title;
  final String? subTitle;
  const ErrorDialog({super.key, this.title, this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: GlassContainer(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            spacing: 20,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  title ?? 'Authentication Required',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                subTitle ?? 'Please authenticate first to use other features.',
              ),
              AppButton(
                onTap: () => Get.back(),
                text: 'Back',
                backgroundColor: Pallet.primaryDarkColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
