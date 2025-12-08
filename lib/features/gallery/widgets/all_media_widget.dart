import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  @override
  Widget build(BuildContext context) {
    GalleryController galleryController = Get.find();
    return galleryController.getMediaList(mediaType).isEmpty
        ? Center(
            child: Text(
              'Nothing to show here',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          )
        : ListView.builder(
            itemCount: galleryController.getMediaList(mediaType).length,
            itemBuilder: (context, index) {
              return Semantics(
                identifier: 'media_container',
                label: 'Media Container to display image, video etc',
                child: GestureDetector(
                  onTap: forMedia
                      ? () {
                          if (forVideo && !singleVideo) {
                            if (galleryController.selectedMedia.contains(
                              galleryController.getMediaList(mediaType)[index],
                            )) {
                              galleryController.selectedMedia.remove(
                                galleryController.getMediaList(
                                  mediaType,
                                )[index],
                              );
                            } else {
                              galleryController.selectedMedia.add(
                                galleryController.getMediaList(
                                  mediaType,
                                )[index],
                              );
                            }
                          } else {
                            Get.back();
                            onSelect([
                              galleryController.getMediaList(mediaType)[index],
                            ]);
                          }
                        }
                      : null,
                  child: MediaContainer(
                    key: ValueKey(
                      galleryController.getMediaList(mediaType)[index],
                    ),
                    path: galleryController.getMediaList(mediaType)[index],
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
