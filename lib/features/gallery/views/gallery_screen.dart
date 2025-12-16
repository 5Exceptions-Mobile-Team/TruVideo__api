import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/gallery/controller/gallery_controller.dart';

import '../../common/widgets/app_button.dart';
import '../../common/widgets/common_app_bar.dart';
import '../widgets/add_dialog.dart';
import '../widgets/all_media_widget.dart';

class GalleryScreen extends StatefulWidget {
  final bool forMedia;
  final ValueChanged<List<String>?> onSelect;
  final bool forVideo;
  final bool singleVideo;
  const GalleryScreen({
    super.key,
    this.forMedia = false,
    required this.onSelect,
    this.forVideo = false,
    this.singleVideo = false,
  });

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late GalleryController galleryController;

  @override
  void initState() {
    galleryController = Get.put(GalleryController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Gallery',
        leading: Obx(
          () => galleryController.selectEnabled.value
              ? Semantics(
                  identifier: 'disable_selection',
                  label: 'Disable media selection',
                  child: IconButton(
                    onPressed: () => galleryController.enableDisableSelection(),
                    icon: Icon(CupertinoIcons.xmark),
                  ),
                )
              : Semantics(
                  identifier: 'back',
                  label: 'Back Button',
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.arrow_back),
                  ),
                ),
        ),
        actions: [
          Obx(
            () => galleryController.selectEnabled.value
                ? Semantics(
                    identifier: 'delete_media',
                    label: 'Delete selected media',
                    child: IconButton(
                      onPressed: () => galleryController.deleteMedia(),
                      icon: Icon(Icons.delete_forever),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          if (!widget.forVideo)
            Obx(
              () => !galleryController.selectEnabled.value
                  ? Semantics(
                      identifier: 'enable_selection',
                      label: 'Enable media selection',
                      child: IconButton(
                        onPressed: () =>
                            galleryController.enableDisableSelection(),
                        icon: Icon(Icons.select_all_rounded),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
        ],
      ),
      floatingActionButton: Semantics(
        identifier: 'add_media_dialog',
        label: 'Show add media dialog',
        child: FloatingActionButton(
          backgroundColor: Pallet.secondaryColor,
          onPressed: () => showDialog(
            context: context,
            builder: (context) => AddMediaDialog(),
          ),
          child: Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
      persistentFooterButtons: [
        if (widget.forVideo && !widget.singleVideo)
          Semantics(
            identifier: 'select_media',
            label: 'Select media button',
            child: AppButton(
              text: 'Select',
              onTap: () {
                Get.back();
                widget.onSelect(List.from(galleryController.selectedMedia));
              },
            ),
          ),
      ],
      body: SafeArea(
        child: widget.forVideo
            ? Column(
                children: [
                  const SizedBox(height: 20),
                  GetBuilder<GalleryController>(
                    id: 'update_media_list',
                    builder: (_) {
                      return Flexible(
                        child: AllMediaWidget(
                          mediaType: '2',
                          forMedia: widget.forMedia,
                          forVideo: widget.forVideo,
                          singleVideo: widget.singleVideo,
                          onSelect: (value) => widget.onSelect(value),
                        ),
                      );
                    },
                  ),
                ],
              )
            : DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    TabBar(
                      unselectedLabelColor: Pallet.tertiaryColor,
                      unselectedLabelStyle: TextStyle(
                        color: Pallet.tertiaryColor,
                      ),
                      indicatorAnimation: TabIndicatorAnimation.elastic,
                      tabs: [
                        Semantics(
                          identifier: 'all_media',
                          label: 'All media tab',
                          child: Tab(child: Text('All')),
                        ),
                        Semantics(
                          identifier: 'image_tab',
                          label: 'Image Tab',
                          child: Tab(child: Icon(Icons.image)),
                        ),
                        Semantics(
                          identifier: 'video_tab',
                          label: 'Video Tab',
                          child: Tab(
                            child: Icon(Icons.video_camera_back_rounded),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GetBuilder<GalleryController>(
                      id: 'update_media_list',
                      builder: (_) {
                        return Expanded(
                          child: TabBarView(
                            children: [
                              AllMediaWidget(
                                mediaType: '0',
                                forMedia: widget.forMedia,
                                onSelect: (value) => widget.onSelect(value),
                              ),
                              AllMediaWidget(
                                mediaType: '1',
                                forMedia: widget.forMedia,
                                onSelect: (value) => widget.onSelect(value),
                              ),
                              AllMediaWidget(
                                mediaType: '2',
                                forMedia: widget.forMedia,
                                onSelect: (value) => widget.onSelect(value),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
