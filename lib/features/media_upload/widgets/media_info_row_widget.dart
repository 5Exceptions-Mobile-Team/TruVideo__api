import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/features/media_upload/controller/media_upload_controller.dart';

class MediaInfoRowWidget extends StatelessWidget {
  final MediaUploadController controller;

  const MediaInfoRowWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Type: ${controller.mediaType.value}'),
          if (controller.mediaType.value == 'VIDEO' && controller.duration.value != '0')
            Text('Duration: ${controller.duration.value}'),
        ],
      ),
    );
  }
}
