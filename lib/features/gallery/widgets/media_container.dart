import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/core/services/web_media_storage_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../controller/gallery_controller.dart';

class MediaContainer extends StatefulWidget {
  final String path;
  final bool forMedia;
  final bool forVideo;
  final bool singleVideo;
  const MediaContainer({
    super.key,
    required this.path,
    required this.forMedia,
    this.forVideo = false,
    this.singleVideo = false,
  });

  @override
  State<MediaContainer> createState() => _MediaContainerState();
}

class _MediaContainerState extends State<MediaContainer> {
  late GalleryController galleryController;
  late String type;
  late RxBool getMetaData;
  late RxBool leadingEnabled;
  late Widget leadingWidget;
  RxString resOrDuration = ''.obs;
  RxString creationDate = ''.obs;
  RxString fileSize = ''.obs;

  @override
  void initState() {
    galleryController = Get.find();
    getMetaData = false.obs;
    leadingEnabled = false.obs;
    type = galleryController.getMediaType(widget.path);
    getLeading();
    getFileMetaData();
    super.initState();
  }

  void getLeading() async {
    leadingWidget = await galleryController.getLeadingWidget(widget.path, type);
    leadingEnabled.value = true;
  }

  void getFileMetaData() async {
    final metaData = await galleryController.getMediaMetadata(widget.path);
    resOrDuration.value = metaData?.$1 ?? '';
    creationDate.value = metaData?.$2 ?? '';

    // Get file size
    try {
      if (kIsWeb && widget.path.startsWith('web_media_')) {
        final id = widget.path.replaceFirst('web_media_', '');
        final webStorage = WebMediaStorageService();
        final bytes = await webStorage.getMediaBytes(id);
        if (bytes != null) {
          final sizeInMB = bytes.length / (1024 * 1024);
          fileSize.value = sizeInMB < 1
              ? '${(bytes.length / 1024).toStringAsFixed(1)} KB'
              : '${sizeInMB.toStringAsFixed(2)} MB';
        }
      } else if (!kIsWeb) {
        // For mobile/desktop, file size will be shown if available from metadata
        // We can skip file system access here to avoid import issues
        fileSize.value = '';
      }
    } catch (e) {
      fileSize.value = '';
    }

    getMetaData.value = true;
  }

  IconData _getTypeIcon() {
    switch (type) {
      case 'IMAGE':
        return Icons.image_rounded;
      case 'VIDEO':
        return Icons.video_camera_back_rounded;
      case 'AUDIO':
        return Icons.audiotrack_rounded;
      case 'DOCUMENT':
        return Icons.description_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getTypeColor() {
    switch (type) {
      case 'IMAGE':
        return Pallet.primaryColor;
      case 'VIDEO':
        return Pallet.primaryColor;
      case 'AUDIO':
        return Pallet.primaryColor;
      case 'DOCUMENT':
        return Pallet.primaryColor;
      default:
        return Pallet.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = galleryController.selectedMedia.contains(widget.path);
      return Semantics(
        identifier: 'open_select_media',
        label: 'Open or select media',
        child: GestureDetector(
          onTap: widget.forMedia
              ? null
              : galleryController.selectEnabled.value
              ? () {
                  // When in selection mode, tapping anywhere on media toggles selection
                  if (isSelected) {
                    galleryController.selectedMedia.remove(widget.path);
                  } else {
                    galleryController.selectedMedia.add(widget.path);
                  }
                }
              : () => galleryController.openOrSelect(widget.path),
          child: Container(
            decoration: BoxDecoration(
              color: Pallet.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                // Never show blue border - always use normal border
                color: Pallet.glassBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Thumbnail/Preview
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: leadingEnabled.value
                      ? Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Pallet.cardBackgroundSubtle,
                          child: leadingWidget is Image
                              ? leadingWidget
                              : Center(child: leadingWidget),
                        )
                      : Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Pallet.cardBackgroundSubtle,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Pallet.primaryColor,
                            ),
                          ),
                        ),
                ),

                // Top right circular checkbox - Always visible when selection mode is enabled
                if (galleryController.selectEnabled.value)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        if (isSelected) {
                          galleryController.selectedMedia.remove(widget.path);
                        } else {
                          galleryController.selectedMedia.add(widget.path);
                        }
                      },
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Pallet.successColor
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Pallet.successColor
                                : Colors.grey[400]!,
                            width: isSelected ? 0 : 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 22,
                              )
                            : null,
                      ),
                    ),
                  ),

                // Bottom overlay with info
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.85),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // File type badge
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getTypeColor().withOpacity(0.9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getTypeIcon(),
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    type,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // if (fileSize.value.isNotEmpty) ...[
                            //   const Spacer(),
                            //   Text(
                            //     fileSize.value,
                            //     style: GoogleFonts.inter(
                            //       fontSize: 11,
                            //       color: Colors.white,
                            //     ),
                            //   ),
                            // ],
                          ],
                        ),
                        if (resOrDuration.value.isNotEmpty ||
                            creationDate.value.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          if (resOrDuration.value.isNotEmpty)
                            Text(
                              resOrDuration.value,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (creationDate.value.isNotEmpty)
                            Text(
                              creationDate.value,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
