import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_app_bar.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_textfield.dart';
import 'package:media_upload_sample_app/features/home/controller/home_controller.dart';
import 'package:media_upload_sample_app/features/media_upload/controller/media_upload_controller.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/checkboxes_row_widget.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/enhanced_json_viewer_widget.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/media_info_row_widget.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/media_preview_widget.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/number_of_parts_selector_widget.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/tags_section_widget.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/upload_stepper_widget.dart';

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
    super.initState();
    controller = Get.put(MediaUploadController(widget.path));
    homeController = Get.find<HomeController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Media Upload'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MediaPreviewWidget(filePath: widget.path, controller: controller),
              const SizedBox(height: 15),
              const Divider(),
              const SizedBox(height: 15),
              Text(
                'Add Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildLabel('Title'),
              const SizedBox(height: 5),
              Semantics(
                identifier: 'title',
                label: 'title',
                child: CommonTextField(
                  controller: controller.titleController,
                  hintText: 'Title',
                ),
              ),
              const SizedBox(height: 20),
              _buildLabel('Creator Name'),
              const SizedBox(height: 5),
              Semantics(
                identifier: 'creator_name',
                label: 'creator_name',
                child: CommonTextField(
                  controller: controller.creatorController,
                  hintText: 'Creator Name',
                ),
              ),
              const SizedBox(height: 20),
              _buildLabel('Metadata'),
              const SizedBox(height: 5),
              Semantics(
                identifier: 'metadata',
                label: 'metadata',
                child: CommonTextField(
                  controller: controller.metadataController,
                  hintText: 'Metadata',
                ),
              ),
              const SizedBox(height: 20),
              TagsSectionWidget(controller: controller),
              const SizedBox(height: 15),
              NumberOfPartsSelectorWidget(controller: controller),
              const SizedBox(height: 15),
              CheckboxesRowWidget(controller: controller),
              const SizedBox(height: 15),
              MediaInfoRowWidget(controller: controller),
              const SizedBox(height: 20),
              UploadStepperWidget(controller: controller),
              // API Responses Display
              _buildApiResponsesDisplay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      ' $text',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Pallet.secondaryDarkColor,
      ),
    );
  }

  Widget _buildApiResponsesDisplay() {
    return Obx(() {
      if (!homeController.testingMode.value) {
        return const SizedBox.shrink();
      }

      final widgets = <Widget>[];

      // Initialize API
      _addApiSection(
        widgets,
        controller.initializePayload.value,
        controller.initializeResponse.value,
        'Initialize API',
      );

      // Upload API
      if (controller.uploadResponse.value != null) {
        if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 15));
        widgets.add(
          EnhancedJsonViewerWidget(
            jsonData: controller.uploadResponse.value,
            title: 'Upload API Response',
          ),
        );
      }

      // Finalize API
      _addApiSection(
        widgets,
        controller.finalizePayload.value,
        controller.finalizeResponse.value,
        'Finalize API',
      );

      if (widgets.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'API Requests & Responses',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Pallet.secondaryDarkColor,
            ),
          ),
          const SizedBox(height: 10),
          ...widgets,
        ],
      );
    });
  }

  void _addApiSection(
    List<Widget> widgets,
    Map<String, dynamic>? payload,
    Map<String, dynamic>? response,
    String apiName,
  ) {
    if (payload == null && response == null) return;

    if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 15));

    if (payload != null) {
      widgets.add(
        EnhancedJsonViewerWidget(
          jsonData: payload,
          title: '$apiName Request Body',
        ),
      );
    }

    if (response != null) {
      if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 10));
      widgets.add(
        EnhancedJsonViewerWidget(
          jsonData: response,
          title: '$apiName Response',
        ),
      );
    }
  }
}
