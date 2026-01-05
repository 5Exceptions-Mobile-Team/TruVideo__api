import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_app_bar.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_textfield.dart';
import 'package:media_upload_sample_app/features/common/widgets/glass_container.dart';
import 'package:media_upload_sample_app/features/common/widgets/gradient_background.dart';
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MediaPreviewWidget(
                  filePath: widget.path,
                  controller: controller,
                ).animate().fadeIn(duration: 400.ms).scale(),
                const SizedBox(height: 24),

                // Form Section
                GlassContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Media Details',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Pallet.textMain,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('Title'),
                      Semantics(
                        identifier: 'title',
                        label: 'title',
                        child: CommonTextField(
                          controller: controller.titleController,
                          hintText: 'Enter title',
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Creator Name'),
                      Semantics(
                        identifier: 'creator_name',
                        label: 'creator_name',
                        child: CommonTextField(
                          controller: controller.creatorController,
                          hintText: 'Enter creator name',
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Metadata'),
                      Semantics(
                        identifier: 'metadata',
                        label: 'metadata',
                        child: CommonTextField(
                          controller: controller.metadataController,
                          hintText: 'Enter metadata',
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                const SizedBox(height: 20),

                // Tags & Settings Section (Grouped for tidiness)
                GlassContainer(
                  child: Column(
                    children: [
                      TagsSectionWidget(controller: controller),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(color: Pallet.glassBorder),
                      ),
                      NumberOfPartsSelectorWidget(controller: controller),
                      const SizedBox(height: 16),
                      CheckboxesRowWidget(controller: controller),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

                const SizedBox(height: 20),
                GlassContainer(
                  child: MediaInfoRowWidget(controller: controller),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                const SizedBox(height: 24),
                UploadStepperWidget(
                  controller: controller,
                ), // Stepper handles its own layout usually, but maybe wraps internal parts?
                // If stepper is complex transparent widget we might need to wrap it.
                // Assuming it has its own distinct visual blocks, we leave it as is or wrap it.
                // Let's wrap it in a clean glass container if it fits, or leave it transparent.
                // Based on standard Steppers, it might be better standalone or in a container.
                // Let's leave it standalone but maybe add some padding/glass if needed.
                // For now, let's assume it looks okay on gradient or is transparent.

                // API Responses Display
                _buildApiResponsesDisplay(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Pallet.textSecondary,
        ),
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
      _addApiSection(
        widgets,
        controller.uploadPayload.value,
        controller.uploadResponse.value,
        'Upload API',
      );

      // Finalize API
      _addApiSection(
        widgets,
        controller.finalizePayload.value,
        controller.finalizeResponse.value,
        'Finalize API',
      );

      if (widgets.isEmpty) return const SizedBox.shrink();

      // Wrap API Response section in Glass for consistency
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              'API Requests & Responses',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Pallet.textMain,
              ),
            ),
          ),
          ...widgets,
        ],
      ).animate().fadeIn();
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
