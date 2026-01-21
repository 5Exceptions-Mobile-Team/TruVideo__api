import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/core/resourses/endpoints.dart';
import 'package:media_upload_sample_app/features/common/widgets/app_button.dart';
import 'package:media_upload_sample_app/features/media_upload/controller/media_upload_controller.dart';
import 'package:media_upload_sample_app/features/home/controller/home_controller.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/step_header_widget.dart';

class Step4CheckStatusConsole extends StatelessWidget {
  final MediaUploadController controller;
  final HomeController homeController;

  const Step4CheckStatusConsole({
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
                    stepNumber: 4,
                    stepTitle: 'Check Status',
                    icon: Icons.verified_rounded,
                    color: Colors.blue,
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
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'GET',
                      style: GoogleFonts.firaCode(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
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
                        '$baseUrl/upload/$uploadId',
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

          // Info Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Pallet.warningColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Pallet.warningColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: Pallet.warningColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'After completing Step 3, the server processes your file asynchronously. You need to check the status to see when it\'s ready.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Pallet.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Button
          Obx(() {
            // Watch isInitializeComplete to check if uploadId is available
            final hasUploadId =
                controller.isInitializeComplete.value &&
                controller.uploadId != null;
            final isLoading =
                controller.isStepLoading.value &&
                controller.currentStep.value == 3;
            return AppButton(
              onTap: !hasUploadId
                  ? () {}
                  : isLoading
                  ? () {}
                  : () => controller.checkUploadStatusOnce(),
              text: isLoading ? 'Checking...' : 'Check Status',
              showLoading: isLoading,
            );
          }),
          const SizedBox(height: 24),

          // Request Display (sample or actual)
          Obx(() {
            if (controller.pollStatusPayload.value != null) {
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
    final endpoint = '$baseUrl/upload/$uploadId';

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
                  'Example Request - Click "Check Status" to see the actual request',
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
            '''GET $endpoint

Headers:
  Authorization: Bearer YOUR_ACCESS_TOKEN

Note: This is a GET request with no body. The response will show the current upload status.''',
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
    final endpoint = '$baseUrl/upload/$uploadId';

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
            '''GET $endpoint

Headers:
  Authorization: Bearer YOUR_ACCESS_TOKEN

Note: This is a GET request with no body. The response will show the current upload status.''',
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
}
