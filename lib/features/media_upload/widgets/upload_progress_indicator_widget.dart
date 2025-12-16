import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/media_upload/controller/media_upload_controller.dart';

class UploadProgressIndicatorWidget extends StatelessWidget {
  final MediaUploadController controller;

  const UploadProgressIndicatorWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.isStepLoading.value && controller.currentStep.value == 1
          ? Padding(
              padding: const EdgeInsets.only(top: 12, left: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Uploading part ${controller.currentUploadPart.value}/${controller.totalUploadParts.value}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Pallet.secondaryDarkColor,
                        ),
                      ),
                      Text(
                        '${controller.uploadProgress.value.toStringAsFixed(0)} %',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Pallet.secondaryDarkColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: controller.uploadProgress.value / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Pallet.secondaryColor,
                    ),
                    minHeight: 6,
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
