import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/resourses/pallet.dart';
import '../controller/gallery_controller.dart';
import 'dart:ui';

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

  @override
  void initState() {
    galleryController = Get.put(GalleryController());
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
    getMetaData.value = true;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Semantics(
        identifier: 'open_select_media',
        label: 'Open or select media',
        child: GestureDetector(
          onTap: widget.forMedia
              ? null
              : () => galleryController.openOrSelect(widget.path),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.09),
                      blurRadius: 10,
                      offset: const Offset(1, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: leadingEnabled.value
                      ? leadingWidget
                      : const SizedBox.shrink(),
                  title: Text(
                    'Type: $type',
                    style: const TextStyle(
                      fontSize: 12,
                      // color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (resOrDuration.value.isNotEmpty)
                        Text(
                          resOrDuration.value,
                          style: const TextStyle(
                            fontSize: 12,
                            // color: Colors.white70,
                          ),
                        ),
                      Text(
                        creationDate.value,
                        style: const TextStyle(
                          fontSize: 12,
                          // color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  trailing:
                      galleryController.selectEnabled.value ||
                          widget.forVideo && !widget.singleVideo
                      ? Checkbox(
                          activeColor: Pallet.secondaryDarkColor,
                          value: galleryController.selectedMedia.contains(
                            widget.path,
                          ),
                          onChanged: (_) {
                            if (widget.forVideo) {
                              if (galleryController.selectedMedia.contains(
                                widget.path,
                              )) {
                                galleryController.selectedMedia.remove(
                                  widget.path,
                                );
                              } else {
                                galleryController.selectedMedia.add(
                                  widget.path,
                                );
                              }
                            } else {
                              galleryController.openOrSelect(widget.path);
                            }
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),

          // child: Container(
          //   margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          //   decoration: BoxDecoration(
          //     color: Colors.grey.withOpacity(0.2),
          //     // color: Colors.grey[400],
          //     borderRadius: BorderRadius.circular(10),
          //   ),
          //   child: ListTile(
          //     leading: leadingEnabled.value
          //         ? leadingWidget
          //         : const SizedBox.shrink(),
          //     title: Text(
          //       'Type: $type',
          //       style: TextStyle(
          //         fontSize: 12,
          //         color: Colors.white,
          //         fontWeight: FontWeight.w500,
          //       ),
          //     ),
          //     subtitle: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         if (resOrDuration.value.isNotEmpty)
          //           Text(
          //             resOrDuration.value,
          //             style: TextStyle(
          //               fontSize: 12,
          //               color: Colors.white,
          //               fontWeight: FontWeight.w500,
          //             ),
          //           ),
          //         Text(
          //           creationDate.value,
          //           style: TextStyle(
          //             fontSize: 12,
          //             color: Colors.white,
          //             fontWeight: FontWeight.w500,
          //           ),
          //         ),
          //       ],
          //     ),
          //     trailing:
          //         galleryController.selectEnabled.value ||
          //             widget.forVideo && !widget.singleVideo
          //         ? Semantics(
          //             identifier: 'select_media',
          //             label: 'Select Media',
          //             child: Checkbox(
          //               activeColor: Pallet.secondaryDarkColor,
          //               value: galleryController.selectedMedia.contains(
          //                 widget.path,
          //               ),
          //               onChanged: (_) {
          //                 if (widget.forVideo) {
          //                   if (galleryController.selectedMedia.contains(
          //                     widget.path,
          //                   )) {
          //                     galleryController.selectedMedia.remove(
          //                       widget.path,
          //                     );
          //                   } else {
          //                     galleryController.selectedMedia.add(widget.path);
          //                   }
          //                 } else {
          //                   galleryController.openOrSelect(widget.path);
          //                 }
          //               },
          //             ),
          //           )
          //         : null,
          //   ),
          // ),
        ),
      ),
    );
  }
}
