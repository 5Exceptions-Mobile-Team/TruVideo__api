import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/core/services/web_media_storage_service.dart';
import 'package:media_upload_sample_app/features/media_upload/controller/media_upload_controller.dart';
import 'package:open_filex/open_filex.dart';

class MediaPreviewWidget extends StatelessWidget {
  final String filePath;
  final MediaUploadController controller;
  static final WebMediaStorageService _webStorage = WebMediaStorageService();

  const MediaPreviewWidget({
    super.key,
    required this.filePath,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        identifier: 'open_media',
        label: 'open_media',
        child: GestureDetector(
          onTap: () {
            if (!kIsWeb) {
              try {
                OpenFilex.open(filePath);
              } catch (e) {
                if (kDebugMode) {
                  print('Error opening file: $e');
                }
              }
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
                      // Handle web paths
                      if (kIsWeb && filePath.startsWith('web_media_')) {
                        return FutureBuilder<Uint8List?>(
                          future: _webStorage.getMediaBytes(
                            filePath.replaceFirst('web_media_', ''),
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasData && snapshot.data != null) {
                              return Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(Icons.broken_image, size: 50),
                                  );
                                },
                              );
                            }
                            return Center(
                              child: Icon(Icons.broken_image, size: 50),
                            );
                          },
                        );
                      } else {
                        // Mobile/Desktop: Use file system
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
      ),
    );
  }
}
