import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/common/widgets/app_button.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_textfield.dart';
import 'package:media_upload_sample_app/features/media_upload/controller/media_upload_controller.dart';
import 'package:media_upload_sample_app/features/home/controller/home_controller.dart';
import 'package:media_upload_sample_app/features/gallery/controller/gallery_controller.dart';
import 'package:media_upload_sample_app/features/gallery/views/gallery_screen.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/checkboxes_row_widget.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/metadata_section_widget.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/number_of_parts_selector_widget.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/tags_section_widget.dart';

class Step1StartUploadConsole extends StatelessWidget {
  final MediaUploadController controller;
  final HomeController homeController;

  const Step1StartUploadConsole({
    super.key,
    required this.controller,
    required this.homeController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Pallet.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Pallet.glassBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Heading
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Pallet.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Pallet.primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Step 1: Start Upload',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Pallet.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Header
          Text(
            'API Endpoint',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Pallet.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Pallet.cardBackgroundSubtle,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Pallet.glassBorder, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Pallet.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'POST',
                    style: GoogleFonts.firaCode(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Pallet.successColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'https://upload-api.truvideo.com/upload/start',
                    style: GoogleFonts.firaCode(
                      fontSize: 12,
                      color: Pallet.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // File Selection Section
          Obx(() {
            final hasFile = controller.activeFilePath != null;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select File',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Pallet.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                if (!hasFile) ...[
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          onTap: () async {
                            // Use gallery controller's pickFile method which handles everything
                            final galleryController = Get.find<GalleryController>();
                            final previousCount = galleryController.allMediaPaths.length;
                            galleryController.pickFile();
                            // After picking, get the latest file from gallery
                            await Future.delayed(const Duration(milliseconds: 1000));
                            // Refresh media list
                            galleryController.getMediaPath();
                            // Get the most recent file from all media paths
                            await Future.delayed(const Duration(milliseconds: 200));
                            if (galleryController.allMediaPaths.length > previousCount) {
                              final latestPath = galleryController.allMediaPaths.first;
                              controller.setFilePath(latestPath);
                            }
                          },
                          text: 'Pick File',
                          showLoading: false,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          onTap: () {
                            Get.to(() => GalleryScreen(
                              onSelect: (paths) {
                                if (paths != null && paths.isNotEmpty) {
                                  controller.setFilePath(paths.first);
                                  Get.back();
                                }
                              },
                            ));
                          },
                          text: 'From Gallery',
                          showLoading: false,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Pallet.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Pallet.successColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Pallet.successColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'File Selected',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Pallet.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                controller.activeFilePath ?? '',
                                style: GoogleFonts.firaCode(
                                  fontSize: 11,
                                  color: Pallet.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            );
          }),

          // Form Fields
          Text(
            'Request Body',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Pallet.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),

          // Amount of Parts
          _buildLabel('Number of Parts', isRequired: false),
          NumberOfPartsSelectorWidget(controller: controller),
          const SizedBox(height: 20),

          // Media Object
          Text(
            'Media Details',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Pallet.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          _buildLabel('Title', isRequired: true),
          CommonTextField(
            controller: controller.titleController,
            hintText: 'Enter title',
          ),
          const SizedBox(height: 16),

          _buildLabel('Creator Name', isRequired: true),
          CommonTextField(
            controller: controller.creatorController,
            hintText: 'Enter creator name',
          ),
          const SizedBox(height: 20),

          // Tags
          TagsSectionWidget(controller: controller),
          const SizedBox(height: 20),

          // Metadata
          MetadataSectionWidget(controller: controller),
          const SizedBox(height: 20),

          // Checkboxes
          CheckboxesRowWidget(controller: controller),
          const SizedBox(height: 24),

          // Action Button
          Obx(
            () => AppButton(
              onTap: controller.isInitializeComplete.value
                  ? () {}
                  : controller.isStepLoading.value &&
                          controller.currentStep.value == 0
                      ? () {}
                      : controller.onInitialize,
              text: controller.isStepLoading.value &&
                      controller.currentStep.value == 0
                  ? 'Initializing...'
                  : 'Initialize Upload',
              showLoading: controller.isStepLoading.value &&
                  controller.currentStep.value == 0,
            ),
          ),
          const SizedBox(height: 24),

          // Request Display (sample or actual)
          Obx(() {
            if (controller.initializePayload.value != null) {
              // Show actual request
              return _buildActualRequest(context);
            }
            // Show sample request by default
            return _buildSampleRequest(context);
          }),
        ],
      ),
    );
  }

  Widget _buildSampleRequest(BuildContext context) {
    final baseUrl = 'https://upload-api.truvideo.com';
    final endpoint = '$baseUrl/upload/start';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: Colors.blue[700],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Example Request - Fill in the form and click "Initialize Upload" to see the actual request',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Sample Request',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Pallet.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF45475A),
              width: 1,
            ),
          ),
          child: SelectableText(
            '''POST $endpoint

Headers:
  Authorization: Bearer YOUR_ACCESS_TOKEN
  Content-Type: application/json

Body:
  {
    "amountOfParts": 1,
    "media": {
      "fileType": "png",
      "title": "My File",
      "creator": "John Doe",
      "duration": 0,
      "resolution": "NORMAL",
      "tags": {},
      "insights": {
        "includeInReport": false,
        "isLibrary": false
      }
    }
  }''',
            style: GoogleFonts.firaCode(
              fontSize: 13,
              color: const Color(0xFFD4D4D4),
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActualRequest(BuildContext context) {
    final baseUrl = 'https://upload-api.truvideo.com';
    final endpoint = '$baseUrl/upload/start';
    final payload = controller.initializePayload.value!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.green.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 18,
                color: Colors.green[700],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Actual Request - This is the request that was sent to the API',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Request',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Pallet.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF45475A),
              width: 1,
            ),
          ),
          child: SelectableText(
            '''POST $endpoint

Headers:
  Authorization: Bearer YOUR_ACCESS_TOKEN
  Content-Type: application/json

Body:
${_formatJson(payload)}''',
            style: GoogleFonts.firaCode(
              fontSize: 13,
              color: const Color(0xFFD4D4D4),
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  String _formatJson(Map<String, dynamic> json) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(json);
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
}
