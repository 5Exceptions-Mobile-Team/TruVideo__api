import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/common/widgets/app_button.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_app_bar.dart';
import 'package:media_upload_sample_app/features/common/widgets/gradient_background.dart';
import 'package:media_upload_sample_app/features/gallery/controller/gallery_controller.dart';
import 'camera_modes_screen.dart';
import 'package:truvideo_camera_sdk/truvideo_sdk_camera_flash_mode.dart';
import 'package:truvideo_camera_sdk/truvideo_sdk_camera_lens_facing.dart';
import 'package:truvideo_camera_sdk/truvideo_sdk_camera_orientation.dart';

class CameraConfigurationScreen extends StatefulWidget {
  const CameraConfigurationScreen({super.key});

  @override
  State<CameraConfigurationScreen> createState() =>
      _CameraConfigurationScreenState();
}

class _CameraConfigurationScreenState extends State<CameraConfigurationScreen> {
  late GalleryController galleryController;

  @override
  void initState() {
    super.initState();
    galleryController = Get.find();
    // Initialize default camera mode if not set
    if (galleryController.cameraMode == null) {
      galleryController.cameraMode = CameraModeEnum.videoAndImage;
      galleryController.update(['camera_mode']);
    }
  }

  String _getCameraModeName() {
    if (galleryController.cameraMode == null) {
      return 'Video and Image (Default)';
    }
    switch (galleryController.cameraMode!) {
      case CameraModeEnum.videoAndImage:
        return 'Video and Image';
      case CameraModeEnum.video:
        return 'Video';
      case CameraModeEnum.image:
        return 'Image';
      case CameraModeEnum.singleVideo:
        return 'Single Video';
      case CameraModeEnum.singleImage:
        return 'Single Image';
      case CameraModeEnum.singleMedia:
        return 'Single Media';
      case CameraModeEnum.singleVideoAndImage:
        return 'Single Video or Image';
    }
  }

  void _resetToDefaults() {
    galleryController.cameraMode = CameraModeEnum.videoAndImage;
    galleryController.selectedLensFacing.value =
        TruvideoSdkCameraLensFacing.back;
    galleryController.selectedFlashMode.value = TruvideoSdkCameraFlashMode.off;
    galleryController.selectedOrientation.value =
        TruvideoSdkCameraOrientation.portrait;
    galleryController.update(['camera_mode']);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _resetToDefaults();
        }
      },
      child: GradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: CommonAppBar(
            title: 'Camera Configuration',
            leading: Semantics(
              identifier: 'back_button',
              label: 'back_button',
              child: IconButton(
                onPressed: () {
                  _resetToDefaults();
                  Get.back();
                },
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
          ),
          persistentFooterButtons: [
            Semantics(
              identifier: 'open_camera',
              label: 'Open Camera',
              child: AppButton(
                text: 'Open Camera',
                onTap: () => galleryController.openSdkCamera(),
                backgroundColor: Pallet.primaryColor,
              ),
            ),
            const SizedBox(height: 5),
          ],
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Camera Mode Section
                  GetBuilder<GalleryController>(
                    id: 'camera_mode',
                    builder: (_) => GestureDetector(
                      onTap: () {
                        Get.to(() => const CameraModesScreen());
                      },
                      child: _buildSection(
                        title: 'Camera Mode',
                        icon: Icons.videocam_rounded,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Pallet.cardBackgroundSubtle,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Pallet.glassBorder,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getCameraModeName(),
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Pallet.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Tap to change mode',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Pallet.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Pallet.textSecondary,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Lens Facing Section
                  _buildSection(
                    title: 'Lens Facing',
                    icon: Icons.camera_alt_rounded,
                    child: Obx(
                      () => Column(
                        children: [
                          _buildCheckboxOption(
                            title: 'Back',
                            value:
                                galleryController.selectedLensFacing.value ==
                                TruvideoSdkCameraLensFacing.back,
                            onChanged: (value) {
                              if (value == true) {
                                galleryController.selectedLensFacing.value =
                                    TruvideoSdkCameraLensFacing.back;
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildCheckboxOption(
                            title: 'Front',
                            value:
                                galleryController.selectedLensFacing.value ==
                                TruvideoSdkCameraLensFacing.front,
                            onChanged: (value) {
                              if (value == true) {
                                galleryController.selectedLensFacing.value =
                                    TruvideoSdkCameraLensFacing.front;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Flash Mode Section
                  _buildSection(
                    title: 'Flash Mode',
                    icon: Icons.flash_on_rounded,
                    child: Obx(
                      () => Column(
                        children: [
                          _buildCheckboxOption(
                            title: 'Off',
                            value:
                                galleryController.selectedFlashMode.value ==
                                TruvideoSdkCameraFlashMode.off,
                            onChanged: (value) {
                              if (value == true) {
                                galleryController.selectedFlashMode.value =
                                    TruvideoSdkCameraFlashMode.off;
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildCheckboxOption(
                            title: 'On',
                            value:
                                galleryController.selectedFlashMode.value ==
                                TruvideoSdkCameraFlashMode.on,
                            onChanged: (value) {
                              if (value == true) {
                                galleryController.selectedFlashMode.value =
                                    TruvideoSdkCameraFlashMode.on;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Orientation Section
                  _buildSection(
                    title: 'Orientation',
                    icon: Icons.screen_rotation_rounded,
                    child: Obx(
                      () => Column(
                        children: [
                          _buildCheckboxOption(
                            title: 'Portrait',
                            value:
                                galleryController.selectedOrientation.value ==
                                TruvideoSdkCameraOrientation.portrait,
                            onChanged: (value) {
                              if (value == true) {
                                galleryController.selectedOrientation.value =
                                    TruvideoSdkCameraOrientation.portrait;
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildCheckboxOption(
                            title: 'Landscape Left',
                            value:
                                galleryController.selectedOrientation.value ==
                                TruvideoSdkCameraOrientation.landscapeLeft,
                            onChanged: (value) {
                              if (value == true) {
                                galleryController.selectedOrientation.value =
                                    TruvideoSdkCameraOrientation.landscapeLeft;
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildCheckboxOption(
                            title: 'Landscape Right',
                            value:
                                galleryController.selectedOrientation.value ==
                                TruvideoSdkCameraOrientation.landscapeRight,
                            onChanged: (value) {
                              if (value == true) {
                                galleryController.selectedOrientation.value =
                                    TruvideoSdkCameraOrientation.landscapeRight;
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildCheckboxOption(
                            title: 'Portrait Reverse',
                            value:
                                galleryController.selectedOrientation.value ==
                                TruvideoSdkCameraOrientation.portraitReverse,
                            onChanged: (value) {
                              if (value == true) {
                                galleryController.selectedOrientation.value =
                                    TruvideoSdkCameraOrientation
                                        .portraitReverse;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Pallet.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Pallet.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Pallet.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 16, color: Pallet.primaryColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Pallet.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildCheckboxOption({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(true),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: value
              ? Pallet.primaryColor.withValues(alpha: 0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: value
                ? Pallet.primaryColor.withOpacity(0.25)
                : Pallet.glassBorder,
            width: value ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: value ? FontWeight.w600 : FontWeight.w500,
                color: value ? Pallet.primaryColor : Pallet.textPrimary,
              ),
            ),
            Radio<bool>(
              value: true,
              groupValue: value ? true : null,
              onChanged: onChanged,
              activeColor: Pallet.primaryColor,
              fillColor: MaterialStateProperty.resolveWith<Color>((
                Set<MaterialState> states,
              ) {
                if (states.contains(MaterialState.selected)) {
                  return Pallet.primaryColor;
                }
                return Pallet.textSecondary;
              }),
            ),
          ],
        ),
      ),
    );
  }
}
