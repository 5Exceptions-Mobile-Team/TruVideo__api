import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/core/services/web_media_storage_service.dart';
import 'package:media_upload_sample_app/features/gallery/controller/gallery_controller.dart';
import 'package:media_upload_sample_app/features/media_upload/controller/media_upload_controller.dart';

class FileDetailsContainer extends StatelessWidget {
  final MediaUploadController controller;
  final GalleryController galleryController;

  const FileDetailsContainer({
    super.key,
    required this.controller,
    required this.galleryController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final filePath = controller.currentFilePath.value;
      if (filePath == null || filePath.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 32),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Pallet.cardBackgroundAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Pallet.primaryColor.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: Pallet.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'File Details',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Pallet.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() => _buildDetailRow('Type', controller.mediaType.value)),
              const SizedBox(height: 12),
              Obx(() => _buildDetailRow('Size', controller.fileSize.value)),
              const SizedBox(height: 12),
              Obx(() {
                final duration = controller.duration.value;
                if (duration != '0' && duration.isNotEmpty) {
                  return Column(
                    children: [
                      _buildDetailRow('Duration', duration),
                      const SizedBox(height: 12),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),
              Obx(() {
                final resolution = controller.resolution.value;
                if (resolution != 'NORMAL' && resolution.isNotEmpty) {
                  return Column(
                    children: [
                      _buildDetailRow('Resolution', resolution),
                      const SizedBox(height: 12),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),
              FutureBuilder<(String, String)?>(
                future: galleryController.getMediaMetadata(filePath),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    final creationDate = snapshot.data!.$2;
                    return _buildDetailRow('Created', creationDate);
                  }
                  return const SizedBox.shrink();
                },
              ),
              // File name display
              Obx(() {
                final path = controller.currentFilePath.value;
                if (path != null && path.isNotEmpty) {
                  return FutureBuilder<String>(
                    future: _getFileName(path),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Column(
                          children: [
                            const SizedBox(height: 12),
                            _buildDetailRow('File Name', snapshot.data!),
                          ],
                        );
                      }
                      // Fallback to path if filename not available
                      return Column(
                        children: [
                          const SizedBox(height: 12),
                          _buildDetailRow('File Name', path.split('/').last),
                        ],
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Pallet.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Pallet.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Future<String> _getFileName(String filePath) async {
    if (kIsWeb && filePath.startsWith('web_media_')) {
      final webStorage = WebMediaStorageService();
      final id = filePath.replaceFirst('web_media_', '');
      final mediaItem = webStorage.getMediaItem(id);
      return mediaItem?.fileName ?? filePath.split('/').last;
    } else {
      return filePath.split('/').last;
    }
  }
}
