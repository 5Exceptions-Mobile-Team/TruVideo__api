import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';

import '../controller/gallery_controller.dart';
import 'media_container.dart';

class AllMediaWidget extends StatelessWidget {
  final String mediaType;
  final ValueChanged<List<String>?> onSelect;
  final bool forMedia;
  final bool forVideo;
  final bool singleVideo;
  const AllMediaWidget({
    super.key,
    required this.mediaType,
    required this.onSelect,
    required this.forMedia,
    this.forVideo = false,
    this.singleVideo = false,
  });

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (kIsWeb) {
      // Web: More columns for better space utilization
      if (width < 900) {
        return 3;
      } else if (width < 1200) {
        return 4;
      } else {
        return 5;
      }
    } else {
      // Mobile/Desktop
      if (width < 600) {
        return 2; // Mobile: 2 columns
      } else if (width < 900) {
        return 3; // Tablet: 3 columns
      } else {
        return 4; // Desktop: 4 columns
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    GalleryController galleryController = Get.find();
    final mediaList = galleryController.getMediaList(mediaType);
    if (mediaList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Pallet.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Nothing to show here',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Pallet.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add files',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Pallet.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final crossAxisCount = _getCrossAxisCount(context);
    final spacing = 16.0;
    // Reduce aspect ratio for smaller cards, especially on web
    final aspectRatio = kIsWeb ? 0.65 : 0.85;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: aspectRatio,
      ),
      itemCount: mediaList.length,
      itemBuilder: (context, index) {
        final type = galleryController.getMediaType(mediaList[index]);
        return Semantics(
          identifier: type,
          label: type,
          child: GestureDetector(
            onTap: forMedia
                ? () {
                    if (forVideo && !singleVideo) {
                      if (galleryController.selectedMedia.contains(
                        mediaList[index],
                      )) {
                        galleryController.selectedMedia.remove(
                          mediaList[index],
                        );
                      } else {
                        galleryController.selectedMedia.add(mediaList[index]);
                      }
                    } else {
                      Get.back();
                      onSelect([mediaList[index]]);
                    }
                  }
                : null,
            child: MediaContainer(
              key: ValueKey(mediaList[index]),
              path: mediaList[index],
              forMedia: forMedia,
              forVideo: forVideo,
              singleVideo: singleVideo,
            ),
          ),
        );
      },
    );
  }
}
