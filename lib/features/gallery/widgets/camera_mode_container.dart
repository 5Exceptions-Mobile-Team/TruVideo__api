import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/resourses/pallet.dart';
import '../controller/gallery_controller.dart';
import 'camera_mode_textfield.dart';

class CameraModeContainer extends StatelessWidget {
  final String? videoCountHint;
  final String? imageCountHint;
  final String? mediaCountHint;
  final String? videoDurationHint;
  const CameraModeContainer({
    super.key,
    this.videoCountHint,
    this.imageCountHint,
    this.mediaCountHint,
    this.videoDurationHint,
  });

  @override
  Widget build(BuildContext context) {
    GalleryController galleryController = Get.find();
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Pallet.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        spacing: 10,
        children: [
          if (videoCountHint != null)
            Semantics(
              identifier: 'video_count',
              label: 'Max video count field',
              child: CameraModeField(
                hintText: videoCountHint!,
                onChanged: (value) =>
                    galleryController.tempVideoCount = int.parse(value),
              ),
            ),
          if (imageCountHint != null)
            Semantics(
              identifier: 'image_count',
              label: 'Max image count',
              child: CameraModeField(
                hintText: imageCountHint!,
                onChanged: (value) =>
                    galleryController.tempImageCount = int.parse(value),
              ),
            ),
          if (mediaCountHint != null)
            Semantics(
              identifier: 'media_count',
              label: 'Max media count',
              child: CameraModeField(
                hintText: mediaCountHint!,
                onChanged: (value) =>
                    galleryController.tempMediaCount = int.parse(value),
              ),
            ),
          if (videoDurationHint != null)
            Semantics(
              identifier: 'video_duration',
              label: 'Max video duration',
              child: CameraModeField(
                hintText: videoDurationHint!,
                onChanged: (value) =>
                    galleryController.tempVideoDuration = int.parse(value),
              ),
            ),
        ],
      ),
    );
  }
}
