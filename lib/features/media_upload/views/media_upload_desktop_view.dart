import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/gallery/controller/gallery_controller.dart';
import 'package:media_upload_sample_app/features/home/controller/home_controller.dart';
import 'package:media_upload_sample_app/features/media_upload/controller/media_upload_controller.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/file_details_container.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/media_preview_widget_standalone.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/step_descriptions.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/step1_start_upload_console.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/step2_upload_parts_console.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/step3_complete_upload_console.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/step4_check_status_console.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/step_request_response_display.dart';
import 'package:get/get.dart';

class MediaUploadDesktopView extends StatelessWidget {
  final MediaUploadController controller;
  final HomeController homeController;

  const MediaUploadDesktopView({
    super.key,
    required this.controller,
    required this.homeController,
  });

  @override
  Widget build(BuildContext context) {
    final galleryController = Get.find<GalleryController>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Panel - Media Preview (Full Width), Step Descriptions (40%)
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Media Preview Widget (Full Width)
                MediaPreviewWidgetStandalone(
                  controller: controller,
                ).animate().fadeIn(delay: 50.ms).slideY(begin: -0.1),
                const SizedBox(height: 32),
                StepDescriptions.step1()
                    .animate()
                    .fadeIn(delay: 100.ms)
                    .slideX(begin: -0.2),
                const SizedBox(height: 32),
                StepDescriptions.step2()
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .slideX(begin: -0.2),
                const SizedBox(height: 32),
                StepDescriptions.step3()
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .slideX(begin: -0.2),
                const SizedBox(height: 32),
                StepDescriptions.step4()
                    .animate()
                    .fadeIn(delay: 400.ms)
                    .slideX(begin: -0.2),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),

        // Divider
        Container(width: 1, color: Pallet.glassBorder.withOpacity(0.3)),

        // Right Panel - File Details, Step Consoles and Request/Response (60%)
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // File Details Container
                FileDetailsContainer(
                  controller: controller,
                  galleryController: galleryController,
                ).animate().fadeIn(delay: 50.ms).slideY(begin: -0.1),
                const SizedBox(height: 32),
                // Step 1: Start Upload
                Step1StartUploadConsole(
                  controller: controller,
                  homeController: homeController,
                ).animate().fadeIn(delay: 150.ms).slideX(begin: 0.2),
                // Step 1 Request/Response - Full width
                Obx(() {
                  final statusCodeValue = controller.initializeStatusCode.value;
                  final statusCode = statusCodeValue != null
                      ? statusCodeValue.toString()
                      : null;
                  final statusMessage = statusCode != null
                      ? 'Success - Upload initialized'
                      : null;
                  return StepRequestResponseDisplay(
                    requestPayload: controller.initializePayload.value,
                    responseData: controller.initializeResponse.value,
                    requestMethod: 'POST',
                    endpoint: 'https://upload-api.truvideo.com/upload/start',
                    requestHeaders: {
                      'Authorization': 'Bearer YOUR-ACCESS-TOKEN',
                      'Content-Type': 'application/json',
                    },
                    statusCode: statusCode,
                    statusMessage: statusMessage,
                    stepNumber: 1,
                  );
                }),
                const SizedBox(height: 32),

                // Step 2: Upload Parts
                Step2UploadPartsConsole(
                  controller: controller,
                ).animate().fadeIn(delay: 250.ms).slideX(begin: 0.2),
                // Divider after Step 2 console
                const SizedBox(height: 32),

                // Step 3: Complete Upload
                Step3CompleteUploadConsole(
                  controller: controller,
                  homeController: homeController,
                ).animate().fadeIn(delay: 350.ms).slideX(begin: 0.2),
                // Step 3 Request/Response - Full width
                Obx(() {
                  final uploadId = controller.isInitializeComplete.value
                      ? (controller.uploadId ?? 'UPLOAD_ID')
                      : 'UPLOAD_ID';
                  return StepRequestResponseDisplay(
                    requestPayload: controller.finalizePayload.value,
                    responseData: controller.finalizeResponse.value,
                    requestMethod: 'POST',
                    endpoint:
                        'https://upload-api.truvideo.com/upload/$uploadId/complete',
                    requestHeaders: {
                      'Authorization': 'Bearer YOUR-ACCESS-TOKEN',
                      'Content-Type': 'application/json',
                    },
                    statusCode: '202',
                    statusMessage: 'Accepted - Processing asynchronously',
                    stepNumber: 3,
                  );
                }),
                // Divider after Step 3 response
                const SizedBox(height: 32),

                // Step 4: Check Status
                Step4CheckStatusConsole(
                  controller: controller,
                  homeController: homeController,
                ).animate().fadeIn(delay: 450.ms).slideX(begin: 0.2),
                // Step 4 Request/Response - Full width
                Obx(() {
                  final uploadId = controller.isInitializeComplete.value
                      ? (controller.uploadId ?? 'UPLOAD_ID')
                      : 'UPLOAD_ID';
                  final response = controller.pollStatusResponse.value;
                  final requestPayload = controller.pollStatusPayload.value;
                  String? statusCode;
                  String? statusMessage;

                  if (response != null) {
                    final status = response['status'] as String? ?? 'UNKNOWN';
                    statusCode = '200';
                    switch (status) {
                      case 'COMPLETED':
                        statusMessage = 'Upload Completed Successfully';
                        break;
                      case 'PENDING_COMPLETE':
                        statusMessage = 'Processing in Background';
                        break;
                      case 'FAILED':
                        statusMessage = 'Upload Failed';
                        break;
                      default:
                        statusMessage = 'Unknown Status';
                    }
                  }

                  // Build request payload for display
                  Map<String, dynamic>? displayRequestPayload;
                  if (requestPayload != null) {
                    displayRequestPayload = {
                      'method': requestPayload['method'] ?? 'GET',
                      'endpoint': requestPayload['url'] ?? '/upload/$uploadId',
                      'headers': requestPayload['headers'] ?? {},
                    };
                  } else if (response != null) {
                    // Show request even if payload wasn't set (for display purposes)
                    displayRequestPayload = {
                      'method': 'GET',
                      'endpoint': '/upload/$uploadId',
                      'headers': {'Authorization': 'Bearer YOUR-ACCESS-TOKEN'},
                    };
                  }
                  return StepRequestResponseDisplay(
                    requestPayload: displayRequestPayload,
                    responseData: response,
                    requestMethod: 'GET',
                    endpoint:
                        'https://upload-api.truvideo.com/upload/$uploadId',
                    requestHeaders: {
                      'Authorization': 'Bearer YOUR-ACCESS-TOKEN',
                    },
                    statusCode: statusCode,
                    statusMessage: statusMessage,
                    stepNumber: 4,
                  );
                }),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
