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
          onTap: () async {
            if (kIsWeb) {
              // Handle Web Preview
              if (controller.mediaType.value == 'IMAGE') {
                await _showWebImagePreview(context);
              }
            } else {
              // Mobile/Desktop Native Open
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
            height: 250, // Increased height for better visibility
            width: double.infinity,
            decoration: BoxDecoration(
              // Simple clean decoration, image speaks for itself
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildMediaContent(),
                  if (controller.mediaType.value == 'VIDEO')
                    Center(
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
                    ),
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

  Future<void> _showWebImagePreview(BuildContext context) async {
    // For Web, we need to fetch bytes again or pass them.
    // Since FutureBuilder handles it in UI, let's fetch for the dialog.
    Uint8List? bytes;
    if (filePath.startsWith('web_media_')) {
      bytes = await _webStorage.getMediaBytes(
        filePath.replaceFirst('web_media_', ''),
      );
    }

    if (bytes == null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Could not load image preview")));
      return;
    }

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              InteractiveViewer(
                // Allow zooming
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.memory(bytes!, fit: BoxFit.contain),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    shape: const CircleBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
