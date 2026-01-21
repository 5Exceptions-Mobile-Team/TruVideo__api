import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/core/resourses/endpoints.dart';
import 'package:media_upload_sample_app/features/common/widgets/app_button.dart';
import 'package:media_upload_sample_app/features/media_upload/controller/media_upload_controller.dart';
import 'package:media_upload_sample_app/features/home/controller/home_controller.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/step_header_widget.dart';

class Step3CompleteUploadConsole extends StatelessWidget {
  final MediaUploadController controller;
  final HomeController homeController;

  const Step3CompleteUploadConsole({
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
        border: Border.all(color: Pallet.glassBorder, width: 1),
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
          // Step Heading (hidden on mobile)
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              if (isMobile) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  StepHeaderWidget(
                    stepNumber: 3,
                    stepTitle: 'Complete Upload',
                    icon: Icons.check_circle_outline_rounded,
                    color: Pallet.successColor,
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
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
            child: Obx(() {
              // Watch isInitializeComplete to get uploadId
              final uploadId = controller.isInitializeComplete.value
                  ? (controller.uploadId ?? 'UPLOAD_ID')
                  : 'UPLOAD_ID';
              return Row(
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
                    child: Obx(() {
                      final baseUrl = homeController.selectedEnvironment.value == 'Prod'
                          ? Endpoints.uploadProdBaseUrl
                          : Endpoints.uploadRCBaseUrl;
                      return Text(
                        '$baseUrl/upload/$uploadId/complete',
                        style: GoogleFonts.firaCode(
                          fontSize: 12,
                          color: Pallet.textPrimary,
                        ),
                      );
                    }),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 24),

          // Parts Array Display
          Obx(() {
            // Watch isUploadComplete to react when Step 2 completes
            final isUploadComplete = controller.isUploadComplete.value;
            final hasUploadedParts = controller.uploadedParts.isNotEmpty;

            if (!isUploadComplete || !hasUploadedParts) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Pallet.cardBackgroundSubtle,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Pallet.glassBorder, width: 1),
                ),
                child: Center(
                  child: Text(
                    'Complete Step 2 first to upload parts',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Pallet.textSecondary,
                    ),
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parts to Complete',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Pallet.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Pallet.cardBackgroundSubtle,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Pallet.glassBorder, width: 1),
                  ),
                  child: Column(
                    children: controller.uploadedParts.map((part) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: Pallet.successColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Part ${part['partNumber']}: ${part['etag'] ?? 'N/A'}',
                                style: GoogleFonts.firaCode(
                                  fontSize: 12,
                                  color: Pallet.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 24),

          // Action Button
          Obx(() {
            final isComplete = controller.isFinalizeComplete.value;
            final isLoading =
                controller.isStepLoading.value &&
                controller.currentStep.value == 2;
            final isUploadComplete = controller.isUploadComplete.value;
            return AppButton(
              onTap: !isUploadComplete
                  ? () {}
                  : isComplete
                  ? () {}
                  : isLoading
                  ? () {}
                  : controller.onFinalize,
              text: isLoading
                  ? 'Finalizing...'
                  : isComplete
                  ? 'Completed'
                  : 'Complete Upload',
              showLoading: isLoading,
              backgroundColor: isComplete ? Pallet.successColor : null,
              buttonIcon: isComplete
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 20,
                    )
                  : null,
            );
          }),
          const SizedBox(height: 24),

          // Request Display (sample or actual)
          Obx(() {
            if (controller.finalizePayload.value != null) {
              // Show actual request
              return _buildActualRequest();
            }
            // Show sample request by default
            return _buildSampleRequest();
          }),
        ],
      ),
    );
  }

  Widget _buildSampleRequest() {
    final uploadId = controller.isInitializeComplete.value
        ? (controller.uploadId ?? 'UPLOAD_ID')
        : 'UPLOAD_ID';
    final baseUrl = homeController.selectedEnvironment.value == 'Prod'
        ? Endpoints.uploadProdBaseUrl
        : Endpoints.uploadRCBaseUrl;
    final endpoint = '$baseUrl/upload/$uploadId/complete';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
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
                  'Example Request - Click "Complete Upload" to see the actual request',
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
            border: Border.all(color: const Color(0xFF45475A), width: 1),
          ),
          child: SelectableText(
            '''POST $endpoint

Headers:
  Authorization: Bearer YOUR_ACCESS_TOKEN
  Content-Type: application/json

Body:
  {
    "parts": [
      {
        "partNumber": 1,
        "etag": "ETAG_FROM_STEP_2"
      }
    ]
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

  Widget _buildActualRequest() {
    final uploadId = controller.isInitializeComplete.value
        ? (controller.uploadId ?? 'UPLOAD_ID')
        : 'UPLOAD_ID';
    final baseUrl = homeController.selectedEnvironment.value == 'Prod'
        ? Endpoints.uploadProdBaseUrl
        : Endpoints.uploadRCBaseUrl;
    final endpoint = '$baseUrl/upload/$uploadId/complete';
    final payload = controller.finalizePayload.value!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
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
            border: Border.all(color: const Color(0xFF45475A), width: 1),
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
}
