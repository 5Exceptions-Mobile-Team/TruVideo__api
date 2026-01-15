import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/core/services/web_media_storage_service.dart';
import 'package:media_upload_sample_app/features/media_upload/controller/media_upload_controller.dart';
import 'package:media_upload_sample_app/features/media_upload/views/image_preview_screen.dart';
import 'package:media_upload_sample_app/features/media_upload/views/video_preview_screen.dart';

class MediaPreviewWidget extends StatelessWidget {
  final String filePath;
  final MediaUploadController controller;
  static final WebMediaStorageService _webStorage = WebMediaStorageService();

  final double height;

  const MediaPreviewWidget({
    super.key,
    required this.filePath,
    required this.controller,
    this.height = 250,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        identifier: 'open_media',
        label: 'open_media',
        child: GestureDetector(
          onTap: () {
            if (controller.mediaType.value == 'IMAGE') {
              Get.to(
                () => ImagePreviewScreen(filePath: filePath),
                transition: Transition.fadeIn,
              );
            } else if (controller.mediaType.value == 'VIDEO') {
              Get.to(
                () => VideoPreviewScreen(filePath: filePath),
                transition: Transition.fadeIn,
              );
            }
          },
          child: Container(
            height: height,
            constraints: BoxConstraints(
              maxHeight: height,
              maxWidth: double.infinity,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey, width: 0.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildMediaContent(),
                  Obx(() {
                    if (controller.mediaType.value == 'VIDEO') {
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaContent() {
    return Obx(() {
      if (controller.mediaType.value == 'VIDEO') {
        if (controller.thumbnailBytes.value != null) {
          return Image.memory(
            controller.thumbnailBytes.value!,
            fit: BoxFit.cover,
          );
        } else {
          return Container(color: Colors.black);
        }
      } else {
        // Handle web paths
        if (kIsWeb && filePath.startsWith('web_media_')) {
          return FutureBuilder<Uint8List?>(
            future: _webStorage.getMediaBytes(
              filePath.replaceFirst('web_media_', ''),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData && snapshot.data != null) {
                return Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image, size: 50),
                    );
                  },
                );
              }
              return const Center(child: Icon(Icons.broken_image, size: 50));
            },
          );
        } else {
          // Mobile/Desktop: Use file system
          return Image.file(
            File(filePath),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Icon(Icons.broken_image, size: 50));
            },
          );
        }
      }
    });
  }
}
