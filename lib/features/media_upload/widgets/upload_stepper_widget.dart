import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/common/widgets/app_button.dart';
import 'package:media_upload_sample_app/features/media_upload/controller/media_upload_controller.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/upload_progress_indicator_widget.dart';

class UploadStepperWidget extends StatelessWidget {
  final MediaUploadController controller;

  const UploadStepperWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          // Step 1: Initialize
          StepRowWidget(
            stepNumber: 1,
            label: 'Initialize',
            isComplete: controller.isInitializeComplete.value,
            isCurrent: controller.currentStep.value == 0,
            isEnabled: !controller.isInitializeComplete.value,
            isLoading:
                controller.isStepLoading.value &&
                controller.currentStep.value == 0,
            onTap: controller.onInitialize,
          ),
          const SizedBox(height: 12),
          // Step 2: Upload file
          StepRowWidget(
            stepNumber: 2,
            label: 'Upload file',
            isComplete: controller.isUploadComplete.value,
            isCurrent: controller.currentStep.value == 1,
            isEnabled:
                controller.isInitializeComplete.value &&
                !controller.isUploadComplete.value,
            isLoading:
                controller.isStepLoading.value &&
                controller.currentStep.value == 1,
            onTap: controller.onUploadFile,
          ),
          // Progress indicator for upload step
          UploadProgressIndicatorWidget(controller: controller),
          const SizedBox(height: 12),
          // Step 3: Finalize
          StepRowWidget(
            stepNumber: 3,
            label: 'Finalize',
            isComplete: controller.isFinalizeComplete.value,
            isCurrent: controller.currentStep.value == 2,
            isEnabled:
                controller.isUploadComplete.value &&
                !controller.isFinalizeComplete.value,
            isLoading:
                controller.isStepLoading.value &&
                controller.currentStep.value == 2,
            onTap: controller.onFinalize,
          ),
        ],
      ),
    );
  }
}

class StepRowWidget extends StatelessWidget {
  final int stepNumber;
  final String label;
  final bool isComplete;
  final bool isCurrent;
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onTap;

  const StepRowWidget({
    super.key,
    required this.stepNumber,
    required this.label,
    required this.isComplete,
    required this.isCurrent,
    required this.isEnabled,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colors based on state
    Color circleColor;
    Color circleFillColor;
    Color buttonColor;

    if (isComplete) {
      circleColor = Colors.green;
      circleFillColor = Colors.green;
      buttonColor = Colors.green;
    } else if (isCurrent && isEnabled) {
      circleColor = Pallet.secondaryColor;
      circleFillColor = Pallet.secondaryColor;
      buttonColor = Pallet.secondaryColor;
    } else if (isEnabled) {
      circleColor = Pallet.secondaryColor;
      circleFillColor = Colors.transparent;
      buttonColor = Pallet.secondaryColor;
    } else {
      circleColor = Colors.grey[400]!;
      circleFillColor = Colors.transparent;
      buttonColor = Colors.grey[400]!;
    }

    return Row(
      children: [
        // Circular step indicator with number
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: circleColor, width: 2.5),
            color: circleFillColor,
          ),
          child: Center(
            child: isComplete
                ? Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '$stepNumber',
                    style: TextStyle(
                      color: circleFillColor == Colors.transparent
                          ? circleColor
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        // AppButton
        Expanded(
          child: AppButton(
            text: label,
            onTap: isEnabled && !isLoading ? onTap : () {},
            backgroundColor: buttonColor,
            showLoading: isLoading,
            borderRadius: 10,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
