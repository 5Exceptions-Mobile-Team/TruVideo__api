import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_textfield.dart';
import 'package:media_upload_sample_app/features/common/widgets/glass_container.dart';
import 'package:media_upload_sample_app/features/home/controller/home_controller.dart';
import 'package:media_upload_sample_app/features/media_upload/controller/media_upload_controller.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/checkboxes_row_widget.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/enhanced_json_viewer_widget.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/media_info_row_widget.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/media_preview_widget.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/metadata_section_widget.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/number_of_parts_selector_widget.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/tags_section_widget.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/upload_stepper_widget.dart';

class MediaUploadMobileView extends StatelessWidget {
  final MediaUploadController controller;
  final HomeController homeController;
  final String path;

  const MediaUploadMobileView({
    super.key,
    required this.controller,
    required this.homeController,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      thickness: 10,
      interactive: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MediaPreviewWidget(
              filePath: path,
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
                  _buildLabel('Title', isRequired: true),
                  Semantics(
                    identifier: 'title',
                    label: 'title',
                    child: CommonTextField(
                      controller: controller.titleController,
                      hintText: 'Enter title',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Creator Name', isRequired: true),
                  Semantics(
                    identifier: 'creator_name',
                    label: 'creator_name',
                    child: CommonTextField(
                      controller: controller.creatorController,
                      hintText: 'Enter creator name',
                    ),
                  ),
                  const SizedBox(height: 16),
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
                  MetadataSectionWidget(controller: controller),
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
            UploadStepperWidget(controller: controller),

            // API Responses Display
            _buildApiResponsesDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: RichText(
        text: TextSpan(
          text: text,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Pallet.textSecondary,
          ),
          children: isRequired
              ? [
                  TextSpan(
                    text: ' *',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ]
              : [],
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

      // Poll Status API
      _addApiSection(
        widgets,
        null,
        controller.pollStatusResponse.value,
        'Poll Status API',
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
