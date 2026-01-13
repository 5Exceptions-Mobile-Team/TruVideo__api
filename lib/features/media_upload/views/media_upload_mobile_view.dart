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
import 'package:media_upload_sample_app/features/media_upload/widgets/upload_flow_explainer.dart';
import 'package:media_upload_sample_app/features/common/widgets/generic_api_request_display.dart';

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

            // Educational Explainer
            const UploadFlowExplainer()
                .animate()
                .fadeIn(delay: 200.ms)
                .slideY(begin: 0.1),
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
      final widgets = <Widget>[];

      // Initialize API - Only show if we have data
      if (controller.initializePayload.value != null ||
          controller.initializeResponse.value != null) {
        widgets.add(
          _buildApiSection(
            '1. Initialize Upload',
            'POST',
            controller.initializePayload.value ?? {},
            controller.initializeResponse.value,
            '/upload/start',
          ),
        );
      }

      // Upload API - Only show after response is received as requested
      if (controller.uploadResponse.value != null) {
        widgets.add(
          _buildApiSection(
            '2. Secure Transfer (Direct to S3)',
            'PUT',
            {}, // Hide request body
            controller.uploadResponse.value,
            'S3 Presigned URL',
            showRequest: false,
          ),
        );
      }

      // Finalize API
      if (controller.finalizePayload.value != null ||
          controller.finalizeResponse.value != null) {
        widgets.add(
          _buildApiSection(
            '3. Complete Upload',
            'POST',
            controller.finalizePayload.value ?? {},
            controller.finalizeResponse.value,
            '/upload/{id}/complete',
          ),
        );
      }

      // Poll Status API
      if (controller.pollStatusPayload.value != null ||
          controller.pollStatusResponse.value != null) {
        widgets.add(
          _buildApiSection(
            '4. Verification Status',
            'GET',
            controller.pollStatusPayload.value ?? {},
            controller.pollStatusResponse.value,
            '/upload/{id}',
          ),
        );
      }

      if (widgets.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              'Request Timeline',
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

  Widget _buildApiSection(
    String title,
    String method,
    Map<String, dynamic> requestBody,
    Map<String, dynamic>? responseBody,
    String endpoint, {
    bool showRequest = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Pallet.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        if (showRequest) ...[
          GenericApiRequestDisplay(
            title: '$title Request',
            requestMethod: method,
            endpoint: endpoint,
            requestHeaders: const {}, // Headers handled in controller if needed
            requestBody: requestBody,
          ),
        ],
        if (responseBody != null) ...[
          if (showRequest) const SizedBox(height: 8),
          EnhancedJsonViewerWidget(
            jsonData: responseBody,
            title: '$title Response',
            isDark: true,
          ),
        ],
      ],
    );
  }
}
