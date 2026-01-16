import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/common/widgets/gradient_background.dart';
import 'package:media_upload_sample_app/features/gallery/controller/gallery_controller.dart';
import '../../common/widgets/common_app_bar.dart';
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
    galleryController = Get.find();
    // galleryController = Get.put(GalleryController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        // backgroundColor: Colors.transparent,
        appBar: CommonAppBar(
          title: 'Gallery',
          leading: Obx(
            () => galleryController.selectEnabled.value
                ? Semantics(
                    identifier: 'disable_selection',
                    label: 'Disable media selection',
                    child: IconButton(
                      onPressed: () =>
                          galleryController.enableDisableSelection(),
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
          identifier: 'add_media',
          label: 'add_media',
          child: FloatingActionButton.extended(
            backgroundColor: Pallet.primaryColor,
            onPressed: () => galleryController.pickFile(),
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
            label: Text(
              'Add File',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
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
                  length: 5,
                  child: Column(
                    children: [
                      // Stats header
                      GetBuilder<GalleryController>(
                        id: 'update_media_list',
                        builder: (_) {
                          final total = galleryController.allMediaPaths.length;
                          final images = galleryController.imagePaths.length;
                          final videos = galleryController.videoPaths.length;
                          final audio = galleryController.audioPaths.length;
                          final docs = galleryController.documentPaths.length;

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Media Library',
                                        style: GoogleFonts.inter(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          color: Pallet.textPrimary,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$total file${total != 1 ? 's' : ''} total',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: Pallet.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (total > 0)
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      if (images > 0)
                                        _buildStatChip(
                                          Icons.image_rounded,
                                          '$images',
                                          Pallet.primaryColor,
                                        ),
                                      if (videos > 0)
                                        _buildStatChip(
                                          Icons.video_camera_back_rounded,
                                          '$videos',
                                          Colors.red,
                                        ),
                                      if (audio > 0)
                                        _buildStatChip(
                                          Icons.audiotrack_rounded,
                                          '$audio',
                                          Colors.purple,
                                        ),
                                      if (docs > 0)
                                        _buildStatChip(
                                          Icons.description_rounded,
                                          '$docs',
                                          Colors.orange,
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                      TabBar(
                        isScrollable: true,
                        labelColor: Pallet.primaryColor,
                        unselectedLabelColor: Pallet.textSecondary,
                        indicatorColor: Pallet.primaryColor,
                        labelStyle: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        tabs: [
                          Semantics(
                            identifier: 'all_media',
                            label: 'All media tab',
                            child: Tab(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.grid_view_rounded, size: 18),
                                  const SizedBox(width: 6),
                                  Text('All'),
                                ],
                              ),
                            ),
                          ),
                          Semantics(
                            identifier: 'image_tab',
                            label: 'Image Tab',
                            child: Tab(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.image_rounded, size: 18),
                                  const SizedBox(width: 6),
                                  Text('Images'),
                                ],
                              ),
                            ),
                          ),
                          Semantics(
                            identifier: 'video_tab',
                            label: 'Video Tab',
                            child: Tab(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.video_camera_back_rounded,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text('Videos'),
                                ],
                              ),
                            ),
                          ),
                          Semantics(
                            identifier: 'audio_tab',
                            label: 'Audio Tab',
                            child: Tab(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.audiotrack_rounded,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text('Audio'),
                                ],
                              ),
                            ),
                          ),
                          Semantics(
                            identifier: 'document_tab',
                            label: 'Document Tab',
                            child: Tab(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.description_rounded,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text('Documents'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
                                AllMediaWidget(
                                  mediaType: '3',
                                  forMedia: widget.forMedia,
                                  onSelect: (value) => widget.onSelect(value),
                                ),
                                AllMediaWidget(
                                  mediaType: '4',
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
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            count,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
