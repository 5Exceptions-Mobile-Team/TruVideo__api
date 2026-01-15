import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/common/widgets/app_button.dart';
import 'package:media_upload_sample_app/features/media_upload/controller/media_upload_controller.dart';

class Step2UploadPartsConsole extends StatelessWidget {
  final MediaUploadController controller;

  const Step2UploadPartsConsole({super.key, required this.controller});

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
                  'Step 2: Upload Parts',
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
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'PUT',
                    style: GoogleFonts.firaCode(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'PRESIGNED_URL (Direct to S3)',
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

          // Info Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Pallet.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Pallet.primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: Pallet.primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This step uploads your file directly to secure cloud storage using presigned URLs from Step 1. The upload happens automatically when you click "Upload File".',
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

          // Presigned URLs Display
          Obx(() {
            // Watch isInitializeComplete to react when Step 1 completes
            final isInitialized = controller.isInitializeComplete.value;
            // Access uploadParts only when initialized (it's not reactive, so we check the reactive flag)
            final uploadParts = isInitialized ? controller.uploadParts : <Map<String, dynamic>>[];
            final hasParts = uploadParts.isNotEmpty;
            final hasPresignedUrl = controller.uploadPresignedUrl != null;

            if (!isInitialized || (!hasParts && !hasPresignedUrl)) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Pallet.cardBackgroundSubtle,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Pallet.glassBorder, width: 1),
                ),
                child: Center(
                  child: Text(
                    'Complete Step 1 first to get presigned URLs',
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
                  'Presigned URLs',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Pallet.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                if (hasParts)
                  ...uploadParts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final part = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Pallet.cardBackgroundSubtle,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Pallet.glassBorder,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Pallet.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Part ${index + 1}',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Pallet.primaryColor,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (isInitialized && controller.uploadedParts.any(
                                  (p) => p['partNumber'] == '${index + 1}',
                                ))
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 18,
                                    color: Pallet.successColor,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              part['presignedUrl'] ?? '',
                              style: GoogleFonts.firaCode(
                                fontSize: 11,
                                color: Pallet.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (part['expiresAt'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Expires: ${part['expiresAt']}',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: Pallet.textSecondary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  })
                else if (hasPresignedUrl)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Pallet.cardBackgroundSubtle,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Pallet.glassBorder, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.uploadPresignedUrl ?? '',
                          style: GoogleFonts.firaCode(
                            fontSize: 11,
                            color: Pallet.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(height: 24),

          // Upload Progress
          Obx(() {
            if (controller.isStepLoading.value &&
                controller.currentStep.value == 1) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Uploading part ${controller.currentUploadPart.value}/${controller.totalUploadParts.value}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Pallet.textPrimary,
                        ),
                      ),
                      Text(
                        '${controller.uploadProgress.value.toStringAsFixed(0)}%',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Pallet.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: controller.uploadProgress.value / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Pallet.primaryColor,
                    ),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(height: 24),

          // Action Button
          Obx(
            () => AppButton(
              onTap: !controller.isInitializeComplete.value
                  ? () {}
                  : controller.isUploadComplete.value
                  ? () {}
                  : controller.isStepLoading.value &&
                        controller.currentStep.value == 1
                  ? () {}
                  : controller.onUploadFile,
              text:
                  controller.isStepLoading.value &&
                      controller.currentStep.value == 1
                  ? 'Uploading...'
                  : controller.isUploadComplete.value
                  ? 'Upload Complete'
                  : 'Upload File',
              showLoading:
                  controller.isStepLoading.value &&
                  controller.currentStep.value == 1,
            ),
          ),
          const SizedBox(height: 24),

          // Request Display (sample or actual)
          Obx(() {
            if (controller.uploadPayload.value != null) {
              // Show actual request
              return _buildActualRequest();
            }
            // Show sample request by default
            return _buildSampleRequest();
          }),
          const SizedBox(height: 24),

          // Uploaded Parts Status
          Obx(() {
            if (!controller.isUploadComplete.value || controller.uploadedParts.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Uploaded Parts',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Pallet.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                ...controller.uploadedParts.map((part) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Pallet.successColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Pallet.successColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: Pallet.successColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Part ${part['partNumber']}',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Pallet.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ETag: ${part['etag'] ?? 'N/A'}',
                                  style: GoogleFonts.firaCode(
                                    fontSize: 11,
                                    color: Pallet.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActualRequest() {
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
                  'Actual Request - This is the request that was sent to S3',
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
            '''PUT https://s3.amazonaws.com/bucket/path/to/file

Headers:
  Content-Type: image/jpeg (or video/mp4, etc.)

Body:
  [Binary file data - file part content]

Note: This upload goes directly to Amazon S3 using the presigned URL from Step 1.
After upload, S3 returns an ETag in the response headers.''',
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

  Widget _buildSampleRequest() {
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
                  'Example Request - Click "Upload File" to see the actual upload request',
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
            '''PUT https://s3.amazonaws.com/bucket/path/to/file

Headers:
  Content-Type: image/jpeg (or video/mp4, etc.)

Body:
  [Binary file data - file part content]

Note: This upload goes directly to Amazon S3 using the presigned URL from Step 1.
After upload, S3 returns an ETag in the response headers.''',
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
