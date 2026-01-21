import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/common/widgets/app_button.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_app_bar.dart';
import 'package:media_upload_sample_app/features/common/widgets/gradient_background.dart';
import 'package:media_upload_sample_app/features/gallery/controller/gallery_controller.dart';
import 'package:media_upload_sample_app/features/gallery/widgets/camera_mode_container.dart';

class CameraModesScreen extends StatelessWidget {
  const CameraModesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    GalleryController galleryController = Get.find();
    return PopScope(
      onPopInvokedWithResult: (_, __) => galleryController.buildCameraMode(),
      child: GradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: CommonAppBar(
            title: 'Camera Modes',
            leading: Semantics(
              identifier: 'back_button',
              label: 'back_button',
              child: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
          ),
          persistentFooterButtons: [
            Semantics(
              identifier: 'confirm_camera_mode',
              label: 'Confirm camera mode',
              child: AppButton(
                text: 'Confirm',
                backgroundColor: Pallet.primaryColor,
                onTap: () => galleryController.updateCameraModeLimits(),
              ),
            ),
            const SizedBox(height: 5),
          ],
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GetBuilder<GalleryController>(
                  id: 'camera_mode',
                  builder: (_) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          identifier: 'video_and_image',
                          label: 'Video and image mode',
                          child: _buildModeOption(
                            title: 'Video and Image',
                            subtitle: 'Capture both videos and images',
                            isSelected:
                                galleryController.tempCameraMode ==
                                CameraModeEnum.videoAndImage,
                            onTap: () => galleryController.changeCameraMode(
                              CameraModeEnum.videoAndImage,
                            ),
                            child:
                                galleryController.tempCameraMode ==
                                    CameraModeEnum.videoAndImage
                                ? CameraModeContainer(
                                    videoCountHint: 'Max video count',
                                    imageCountHint: 'Max image count',
                                    videoDurationHint:
                                        'Max video duration (in milliseconds)',
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Semantics(
                          identifier: 'video_mode',
                          label: 'Video Mode',
                          child: _buildModeOption(
                            title: 'Video',
                            subtitle: 'Capture videos only',
                            isSelected:
                                galleryController.tempCameraMode ==
                                CameraModeEnum.video,
                            onTap: () => galleryController.changeCameraMode(
                              CameraModeEnum.video,
                            ),
                            child:
                                galleryController.tempCameraMode ==
                                    CameraModeEnum.video
                                ? CameraModeContainer(
                                    videoCountHint: 'Max video count',
                                    videoDurationHint:
                                        'Max video duration (in milliseconds)',
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Semantics(
                          identifier: 'image_mode',
                          label: 'Image Mode',
                          child: _buildModeOption(
                            title: 'Image',
                            subtitle: 'Capture images only',
                            isSelected:
                                galleryController.tempCameraMode ==
                                CameraModeEnum.image,
                            onTap: () => galleryController.changeCameraMode(
                              CameraModeEnum.image,
                            ),
                            child:
                                galleryController.tempCameraMode ==
                                    CameraModeEnum.image
                                ? CameraModeContainer(
                                    imageCountHint: 'Max image count',
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Semantics(
                          identifier: 'single_video_mode',
                          label: 'Single Video Mode',
                          child: _buildModeOption(
                            title: 'Single Video',
                            subtitle: 'Capture a single video',
                            isSelected:
                                galleryController.tempCameraMode ==
                                CameraModeEnum.singleVideo,
                            onTap: () => galleryController.changeCameraMode(
                              CameraModeEnum.singleVideo,
                            ),
                            child:
                                galleryController.tempCameraMode ==
                                    CameraModeEnum.singleVideo
                                ? CameraModeContainer(
                                    videoDurationHint:
                                        'Max video duration (in milliseconds)',
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Semantics(
                          identifier: 'single_image_mode',
                          label: 'Single image mode',
                          child: _buildModeOption(
                            title: 'Single Image',
                            subtitle: 'Capture a single image (no limits)',
                            isSelected:
                                galleryController.tempCameraMode ==
                                CameraModeEnum.singleImage,
                            onTap: () => galleryController.changeCameraMode(
                              CameraModeEnum.singleImage,
                            ),
                            child: null, // No limit fields for single image
                          ),
                        ),
                        const SizedBox(height: 12),
                        Semantics(
                          identifier: 'single_media_mode',
                          label: 'Single media mode',
                          child: _buildModeOption(
                            title: 'Single Media',
                            subtitle: 'Capture a single media item',
                            isSelected:
                                galleryController.tempCameraMode ==
                                CameraModeEnum.singleMedia,
                            onTap: () => galleryController.changeCameraMode(
                              CameraModeEnum.singleMedia,
                            ),
                            child:
                                galleryController.tempCameraMode ==
                                    CameraModeEnum.singleMedia
                                ? CameraModeContainer(
                                    mediaCountHint: 'Max media count',
                                    videoDurationHint:
                                        'Max video duration (in milliseconds)',
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Semantics(
                          identifier: 'single_video_or_image_mode',
                          label: 'Single video or image mode',
                          child: _buildModeOption(
                            title: 'Single Video or Image',
                            subtitle: 'Capture either a single video or image',
                            isSelected:
                                galleryController.tempCameraMode ==
                                CameraModeEnum.singleVideoAndImage,
                            onTap: () => galleryController.changeCameraMode(
                              CameraModeEnum.singleVideoAndImage,
                            ),
                            child:
                                galleryController.tempCameraMode ==
                                    CameraModeEnum.singleVideoAndImage
                                ? CameraModeContainer(
                                    videoDurationHint:
                                        'Max video duration (in milliseconds)',
                                  )
                                : null,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    Widget? child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? Pallet.primaryColor.withOpacity(0.08)
                  : Pallet.cardBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? Pallet.primaryColor.withOpacity(0.25)
                    : Pallet.glassBorder,
                width: isSelected ? 1.5 : 1,
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
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? Pallet.primaryColor
                              : Pallet.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Pallet.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Radio<bool>(
                  value: true,
                  groupValue: isSelected ? true : null,
                  onChanged: (_) => onTap(),
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
        ),
        if (child != null) ...[const SizedBox(height: 10), child],
      ],
    );
  }
}
