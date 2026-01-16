import 'package:flutter/material.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/home/controller/home_controller.dart';
import 'package:media_upload_sample_app/features/media_upload/controller/media_upload_controller.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/step_descriptions.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/step1_start_upload_console.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/step2_upload_parts_console.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/step3_complete_upload_console.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/step4_check_status_console.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/step_request_response_display.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/media_preview_widget_standalone.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/file_details_container.dart';
import 'package:media_upload_sample_app/features/gallery/controller/gallery_controller.dart';
import 'package:get/get.dart';

class MediaUploadMobileView extends StatelessWidget {
  final MediaUploadController controller;
  final HomeController homeController;

  const MediaUploadMobileView({
    super.key,
    required this.controller,
    required this.homeController,
  });

  @override
  Widget build(BuildContext context) {
    final galleryController = Get.find<GalleryController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media Preview Widget
          MediaPreviewWidgetStandalone(
            controller: controller,
          ),
          // File Details Container
          FileDetailsContainer(
            controller: controller,
            galleryController: galleryController,
          ),
          // Step 1: Start Upload
          StepDescriptions.step1(),
          const SizedBox(height: 16),
          Step1StartUploadConsole(
            controller: controller,
            homeController: homeController,
          ),
          // Step 1 Request/Response
          Obx(() {
            final statusCodeValue = controller.initializeStatusCode.value;
            final statusCode = statusCodeValue?.toString();
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
          // Divider after Step 1 response
          Obx(
            () => controller.initializeResponse.value != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Divider(
                      color: Pallet.glassBorder.withOpacity(0.3),
                      thickness: 1,
                    ),
                  )
                : const SizedBox(height: 32),
          ),

          // Step 2: Upload Parts
          StepDescriptions.step2(),
          const SizedBox(height: 16),
          Step2UploadPartsConsole(
            controller: controller,
          ),
          // Divider after Step 2 console
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Divider(
              color: Pallet.glassBorder.withOpacity(0.3),
              thickness: 1,
            ),
          ),

          // Step 3: Complete Upload
          StepDescriptions.step3(),
          const SizedBox(height: 16),
          Step3CompleteUploadConsole(
            controller: controller,
            homeController: homeController,
          ),
          // Step 3 Request/Response
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
          Obx(
            () => controller.finalizeResponse.value != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Divider(
                      color: Pallet.glassBorder.withOpacity(0.3),
                      thickness: 1,
                    ),
                  )
                : const SizedBox(height: 32),
          ),

          // Step 4: Check Status
          StepDescriptions.step4(),
          const SizedBox(height: 16),
          Step4CheckStatusConsole(
            controller: controller,
            homeController: homeController,
          ),
          // Step 4 Request/Response
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
              endpoint: 'https://upload-api.truvideo.com/upload/$uploadId',
              requestHeaders: {'Authorization': 'Bearer YOUR-ACCESS-TOKEN'},
              statusCode: statusCode,
              statusMessage: statusMessage,
              stepNumber: 4,
            );
          }),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
