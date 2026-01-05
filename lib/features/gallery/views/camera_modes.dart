// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:media_upload_sample_app/core/resourses/pallet.dart';
// import '../../common/widgets/app_button.dart';
// import '../../common/widgets/common_app_bar.dart';
// import '../controller/gallery_controller.dart';
// import '../widgets/camera_mode_container.dart';
//
// class CameraModesScreen extends StatelessWidget {
//   const CameraModesScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     GalleryController galleryController = Get.find();
//     return PopScope(
//       onPopInvokedWithResult: (_, _) => galleryController.buildCameraMode(),
//       child: Scaffold(
//         appBar: CommonAppBar(title: 'Camera Modes'),
//         persistentFooterButtons: [
//           AppButton(
//             text: 'Confirm',
//             backgroundColor: Pallet.secondaryColor,
//             onTap: () => galleryController.updateCameraModeLimits(),
//           ),
//         ],
//         body: SafeArea(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(15),
//               child: GetBuilder<GalleryController>(
//                 id: 'camera_mode',
//                 builder: (_) {
//                   return Column(
//                     spacing: 20,
//                     children: [
//                       Semantics(
//                         identifier: 'video_and_image',
//                         label: 'Video and image mode',
//                         child: InkWell(
//                           onTap: () => galleryController.changeCameraMode(
//                             CameraModeEnum.videoAndImage,
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Video and image',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                               Checkbox(
//                                 activeColor: Pallet.secondaryColor,
//                                 value:
//                                     galleryController.tempCameraMode ==
//                                     CameraModeEnum.videoAndImage,
//                                 onChanged: (_) =>
//                                     galleryController.changeCameraMode(
//                                       CameraModeEnum.videoAndImage,
//                                     ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(30),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       if (galleryController.tempCameraMode ==
//                           CameraModeEnum.videoAndImage)
//                         CameraModeContainer(
//                           videoCountHint: 'Max video count',
//                           imageCountHint: 'Max image count',
//                           videoDurationHint:
//                               'Max video duration (in milliseconds)',
//                         ),
//                       Semantics(
//                         identifier: 'video_mode',
//                         label: 'Video Mode',
//                         child: InkWell(
//                           onTap: () => galleryController.changeCameraMode(
//                             CameraModeEnum.video,
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Video',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                               Checkbox(
//                                 activeColor: Pallet.secondaryColor,
//                                 value:
//                                     galleryController.tempCameraMode ==
//                                     CameraModeEnum.video,
//                                 onChanged: (_) => galleryController
//                                     .changeCameraMode(CameraModeEnum.video),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(30),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       if (galleryController.tempCameraMode ==
//                           CameraModeEnum.video)
//                         CameraModeContainer(
//                           videoCountHint: 'Max video count',
//                           videoDurationHint:
//                               'Max video duration (in milliseconds)',
//                         ),
//                       Semantics(
//                         identifier: 'image_mode',
//                         label: 'Image Mode',
//                         child: InkWell(
//                           onTap: () => galleryController.changeCameraMode(
//                             CameraModeEnum.image,
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Image',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                               Checkbox(
//                                 activeColor: Pallet.secondaryColor,
//                                 value:
//                                     galleryController.tempCameraMode ==
//                                     CameraModeEnum.image,
//                                 onChanged: (_) => galleryController
//                                     .changeCameraMode(CameraModeEnum.image),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(30),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       if (galleryController.tempCameraMode ==
//                           CameraModeEnum.image)
//                         CameraModeContainer(imageCountHint: 'Max image count'),
//                       Semantics(
//                         identifier: 'single_video_mode',
//                         label: 'Single Video Mode',
//                         child: InkWell(
//                           onTap: () => galleryController.changeCameraMode(
//                             CameraModeEnum.singleVideo,
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Single Video',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                               Checkbox(
//                                 activeColor: Pallet.secondaryColor,
//                                 value:
//                                     galleryController.tempCameraMode ==
//                                     CameraModeEnum.singleVideo,
//                                 onChanged: (_) =>
//                                     galleryController.changeCameraMode(
//                                       CameraModeEnum.singleVideo,
//                                     ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(30),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       if (galleryController.tempCameraMode ==
//                           CameraModeEnum.singleVideo)
//                         CameraModeContainer(
//                           videoDurationHint:
//                               'Max video duration (in milliseconds)',
//                         ),
//                       Semantics(
//                         identifier: 'single_image_mode',
//                         label: 'Single image mode',
//                         child: InkWell(
//                           onTap: () => galleryController.changeCameraMode(
//                             CameraModeEnum.singleImage,
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Single Image',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                               Checkbox(
//                                 activeColor: Pallet.secondaryColor,
//                                 value:
//                                     galleryController.tempCameraMode ==
//                                     CameraModeEnum.singleImage,
//                                 onChanged: (_) =>
//                                     galleryController.changeCameraMode(
//                                       CameraModeEnum.singleImage,
//                                     ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(30),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       Semantics(
//                         identifier: 'single_media_mode',
//                         label: 'Single media mode',
//                         child: InkWell(
//                           onTap: () => galleryController.changeCameraMode(
//                             CameraModeEnum.singleMedia,
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Single Media',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                               Checkbox(
//                                 activeColor: Pallet.secondaryColor,
//                                 value:
//                                     galleryController.tempCameraMode ==
//                                     CameraModeEnum.singleMedia,
//                                 onChanged: (_) =>
//                                     galleryController.changeCameraMode(
//                                       CameraModeEnum.singleMedia,
//                                     ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(30),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       if (galleryController.tempCameraMode ==
//                           CameraModeEnum.singleMedia)
//                         CameraModeContainer(
//                           mediaCountHint: 'Max media count',
//                           videoDurationHint:
//                               'Max video duration (in milliseconds)',
//                         ),
//                       Semantics(
//                         identifier: 'single_video_or_image_mode',
//                         label: 'Single video or image mode',
//                         child: InkWell(
//                           onTap: () => galleryController.changeCameraMode(
//                             CameraModeEnum.singleVideoAndImage,
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Single video or image',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                               Checkbox(
//                                 activeColor: Pallet.secondaryColor,
//                                 value:
//                                     galleryController.tempCameraMode ==
//                                     CameraModeEnum.singleVideoAndImage,
//                                 onChanged: (_) =>
//                                     galleryController.changeCameraMode(
//                                       CameraModeEnum.singleVideoAndImage,
//                                     ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(30),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       if (galleryController.tempCameraMode ==
//                           CameraModeEnum.singleVideoAndImage)
//                         CameraModeContainer(
//                           videoDurationHint:
//                               'Max video duration (in milliseconds)',
//                         ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
