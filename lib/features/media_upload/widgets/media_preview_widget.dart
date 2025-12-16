import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/features/media_upload/controller/media_upload_controller.dart';
import 'package:open_filex/open_filex.dart';

class MediaPreviewWidget extends StatelessWidget {
  final String filePath;
  final MediaUploadController controller;

  const MediaPreviewWidget({
    super.key,
    required this.filePath,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          try {
            OpenFilex.open(filePath);
          } catch (e) {
            print('Error opening file: $e');
          }
        },
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Obx(() {
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
                    return Image.file(
                      File(filePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.broken_image, size: 50),
                        );
                      },
                    );
                  }
                }),
              ),
              Obx(() {
                if (controller.mediaType.value == 'VIDEO') {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
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
    );
  }
}
