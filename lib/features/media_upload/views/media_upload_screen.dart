import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_app_bar.dart';
import 'package:media_upload_sample_app/features/common/widgets/gradient_background.dart';
import 'package:media_upload_sample_app/features/home/controller/home_controller.dart';
import 'package:media_upload_sample_app/features/media_upload/controller/media_upload_controller.dart';
import 'package:media_upload_sample_app/features/media_upload/views/media_upload_desktop_view.dart';
import 'package:media_upload_sample_app/features/media_upload/views/media_upload_mobile_view.dart';

class MediaUploadScreen extends StatefulWidget {
  final String path;
  const MediaUploadScreen({super.key, required this.path});

  @override
  State<MediaUploadScreen> createState() => _MediaUploadScreenState();
}

class _MediaUploadScreenState extends State<MediaUploadScreen> {
  late MediaUploadController controller;
  late HomeController homeController;

  @override
  void initState() {
    controller = Get.put(MediaUploadController(widget.path));
    homeController = Get.find<HomeController>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CommonAppBar(
          title: 'Media Upload',
          leading: Semantics(
            identifier: 'back_button',
            label: 'back_button',
            child: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return MediaUploadDesktopView(
                  controller: controller,
                  homeController: homeController,
                  path: widget.path,
                );
              } else {
                return MediaUploadMobileView(
                  controller: controller,
                  homeController: homeController,
                  path: widget.path,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
