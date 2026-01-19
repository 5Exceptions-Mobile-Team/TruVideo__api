import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/core/utils/app_text_styles.dart';
import 'package:media_upload_sample_app/core/services/web_media_storage_service.dart';
import 'package:media_upload_sample_app/features/gallery/controller/gallery_controller.dart';
import 'package:media_upload_sample_app/features/media_upload/controller/media_upload_controller.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/audio_player_dialog.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/pdf_preview_widget.dart';
import 'package:media_upload_sample_app/features/media_upload/views/image_preview_screen.dart';
import 'package:media_upload_sample_app/features/media_upload/views/video_preview_screen.dart';

class MediaPreviewSection extends StatelessWidget {
  final MediaUploadController controller;
  final GalleryController galleryController;

  const MediaPreviewSection({
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Container
            Expanded(flex: 1, child: _buildPreviewContainer(context, filePath)),
            const SizedBox(width: 16),
            // File Details Container
            Expanded(flex: 1, child: _buildFileDetailsContainer(filePath)),
          ],
        ),
      );
    });
  }

  Widget _buildPreviewContainer(BuildContext context, String filePath) {
    return Obx(() {
      final mediaType = controller.mediaType.value;

      return GestureDetector(
        onTap: () => _openMedia(context, filePath, mediaType),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Pallet.cardBackground,
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _buildPreviewContent(filePath, mediaType),
          ),
        ),
      );
    });
  }

  Widget _buildPreviewContent(String filePath, String mediaType) {
    if (mediaType == 'IMAGE') {
      return _buildImagePreview(filePath);
    } else if (mediaType == 'VIDEO') {
      return _buildVideoPreview(filePath);
    } else if (mediaType == 'AUDIO') {
      return _buildAudioPreview();
    } else if (mediaType == 'DOCUMENT' ||
        filePath.toLowerCase().endsWith('.pdf')) {
      return _buildPdfPreview(filePath);
    } else {
      return _buildGenericPreview(mediaType);
    }
  }

  Widget _buildImagePreview(String filePath) {
    if (kIsWeb && filePath.startsWith('web_media_')) {
      final webStorage = WebMediaStorageService();
      final id = filePath.replaceFirst('web_media_', '');
      return FutureBuilder<Uint8List?>(
        future: webStorage.getMediaBytes(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(snapshot.data!, fit: BoxFit.cover),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.open_in_full,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            );
          }
          return _buildErrorWidget();
        },
      );
    } else {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(filePath),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.open_in_full,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildVideoPreview(String filePath) {
    return Obx(() {
      final thumbnail = controller.thumbnailBytes.value;
      return Stack(
        fit: StackFit.expand,
        children: [
          if (thumbnail != null)
            Image.memory(thumbnail, fit: BoxFit.cover)
          else
            Container(
              color: Colors.black,
              child: const Center(child: CircularProgressIndicator()),
            ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.open_in_full,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildAudioPreview() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Pallet.primaryColor.withOpacity(0.8),
            Pallet.primaryColor.withOpacity(0.6),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_note_rounded, color: Colors.white, size: 60),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Play Audio',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfPreview(String filePath) {
    return PdfPreviewWidget(
      filePath: filePath,
      height: 200,
      showOpenButton: true,
    );
  }

  Widget _buildGenericPreview(String mediaType) {
    IconData icon;
    String label;

    switch (mediaType.toUpperCase()) {
      case 'DOCUMENT':
        icon = Icons.description_rounded;
        label = 'Document';
        break;
      default:
        icon = Icons.insert_drive_file_rounded;
        label = 'File';
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Pallet.secondaryColor.withOpacity(0.8),
            Pallet.secondaryColor.withOpacity(0.6),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 64),
          const SizedBox(height: 16),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Pallet.cardBackgroundAlt,
      child: const Center(
        child: Icon(Icons.broken_image, size: 48, color: Pallet.textSecondary),
      ),
    );
  }

  Widget _buildFileDetailsContainer(String filePath) {
    return Container(
      height: 200,
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
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: AppTextStyles.bodyMedium()),
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

  void _openMedia(BuildContext context, String filePath, String mediaType) {
    if (mediaType == 'IMAGE') {
      Get.to(
        () => ImagePreviewScreen(filePath: filePath),
        transition: Transition.noTransition,
      );
    } else if (mediaType == 'VIDEO') {
      Get.to(
        () => VideoPreviewScreen(filePath: filePath),
        transition: Transition.noTransition,
      );
    } else if (mediaType == 'AUDIO') {
      Get.dialog(
        AudioPlayerDialog(filePath: filePath),
        barrierDismissible: true,
      );
    } else if (mediaType == 'DOCUMENT' ||
        filePath.toLowerCase().endsWith('.pdf')) {
      // PDF preview can be opened in full screen if needed
      // For now, the preview widget handles it
    }
  }
}
