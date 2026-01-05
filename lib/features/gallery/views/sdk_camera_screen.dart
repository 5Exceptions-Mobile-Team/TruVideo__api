// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:truvideo_camera_sdk/camera_configuration.dart';
// import 'package:truvideo_camera_sdk/truvideo_sdk_camera_flash_mode.dart';
// import 'package:truvideo_camera_sdk/truvideo_sdk_camera_lens_facing.dart';
// import 'package:truvideo_camera_sdk/truvideo_sdk_camera_orientation.dart';
// import '../../../core/resourses/pallet.dart';
// import '../../common/widgets/app_button.dart';
// import '../../common/widgets/common_app_bar.dart';
// import '../controller/gallery_controller.dart';
// import 'camera_modes.dart';
//
// class SdkCameraScreen extends StatefulWidget {
//   const SdkCameraScreen({super.key});
//
//   @override
//   State<SdkCameraScreen> createState() => _SdkCameraScreenState();
// }
//
// class _SdkCameraScreenState extends State<SdkCameraScreen> {
//   late GalleryController galleryController;
//   late CameraConfiguration cameraConfiguration;
//   late RxString flashMode;
//   late RxString lensFacing;
//   late RxString orientation;
//
//   @override
//   void initState() {
//     galleryController = Get.find();
//
//     /// 0 = off, 1 = on
//     flashMode = '0'.obs;
//
//     /// 0 = back, 1 = front
//     lensFacing = '0'.obs;
//
//     /// 0 = portrait and so on...
//     orientation = '0'.obs;
//     super.initState();
//   }
//
//   void openSDKCamera() async {
//     Directory dir = await getApplicationDocumentsDirectory();
//
//     String galleryPath = '${dir.path}/gallery';
//
//     final galleryDir = Directory(galleryPath);
//
//     if (!await galleryDir.exists()) {
//       await galleryDir.create(recursive: true);
//     }
//
//     cameraConfiguration = CameraConfiguration(
//       lensFacing: getLensFacing(),
//       flashMode: getFlashMode(),
//       orientation: getOrientation(),
//       outputPath: galleryPath,
//       mode: galleryController.getCameraMode(),
//     );
//
//     galleryController.openCamera(cameraConfiguration, galleryPath);
//   }
//
//   TruvideoSdkCameraLensFacing getLensFacing() {
//     if (lensFacing.value == '0') {
//       return TruvideoSdkCameraLensFacing.back;
//     } else {
//       return TruvideoSdkCameraLensFacing.front;
//     }
//   }
//
//   TruvideoSdkCameraFlashMode getFlashMode() {
//     if (flashMode.value == '0') {
//       return TruvideoSdkCameraFlashMode.off;
//     } else {
//       return TruvideoSdkCameraFlashMode.on;
//     }
//   }
//
//   TruvideoSdkCameraOrientation getOrientation() {
//     if (orientation.value == '2') {
//       return TruvideoSdkCameraOrientation.landscapeLeft;
//     } else if (orientation.value == '3') {
//       return TruvideoSdkCameraOrientation.landscapeRight;
//     } else if (orientation.value == '4') {
//       return TruvideoSdkCameraOrientation.portraitReverse;
//     } else {
//       return TruvideoSdkCameraOrientation.portrait;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       onPopInvokedWithResult: (_, _) {
//         galleryController.videoCount = null;
//         galleryController.imageCount = null;
//         galleryController.mediaCount = null;
//         galleryController.videoDuration = null;
//       },
//       child: Scaffold(
//         appBar: CommonAppBar(title: 'Camera Configuration'),
//         body: SafeArea(
//           child: SingleChildScrollView(
//             child: Obx(
//               () => Column(
//                 children: [
//                   const SizedBox(height: 10),
//                   Semantics(
//                     identifier: 'camera_modes',
//                     label: 'Camera Modes',
//                     child: GestureDetector(
//                       onTap: () {
//                         galleryController.videoCount = null;
//                         galleryController.imageCount = null;
//                         galleryController.mediaCount = null;
//                         galleryController.videoDuration = null;
//                         Get.to(() => CameraModesScreen());
//                       },
//                       child: Container(
//                         width: double.maxFinite,
//                         color: Pallet.secondaryColor,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                           vertical: 15,
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Mode',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             Icon(Icons.arrow_forward_ios_rounded),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   GetBuilder<GalleryController>(
//                     id: 'camera_mode',
//                     builder: (_) => Column(
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 20),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('Media Limit'),
//                               Semantics(
//                                 identifier: 'media_limit',
//                                 label: 'Media limit',
//                                 child: Text(
//                                   galleryController.mediaCount.toString(),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 20),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('Video Limit'),
//                               Semantics(
//                                 identifier: 'video_limit',
//                                 label: 'Video limit',
//                                 child: Text(
//                                   galleryController.videoCount.toString(),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 20),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('Image Limit'),
//                               Semantics(
//                                 identifier: 'image_count',
//                                 label: 'Image count',
//                                 child: Text(
//                                   galleryController.imageCount.toString(),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 20),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('Video Duration Limit'),
//                               Semantics(
//                                 identifier: 'video_duration',
//                                 label: 'Video duration limit',
//                                 child: Text(
//                                   galleryController.videoDuration.toString(),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 20),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('Auto Close'),
//                               Text(galleryController.autoClose.toString()),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Container(
//                     width: double.maxFinite,
//                     color: Pallet.secondaryColor,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 15,
//                     ),
//                     child: Text(
//                       'Flash Mode',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Semantics(
//                     identifier: 'flash_mode_on',
//                     label: 'Flash mode on',
//                     child: InkWell(
//                       onTap: () => flashMode.value = '1',
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'ON',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.black,
//                               ),
//                             ),
//                             Checkbox(
//                               value: flashMode.value == '1',
//                               onChanged: (_) => flashMode.value = '1',
//                               activeColor: Pallet.secondaryColor,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   Semantics(
//                     identifier: 'flash_mode_off',
//                     label: 'Flash mode off',
//                     child: InkWell(
//                       onTap: () => flashMode.value = '0',
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'OFF',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.black,
//                               ),
//                             ),
//                             Checkbox(
//                               value: flashMode.value == '0',
//                               activeColor: Pallet.secondaryColor,
//                               onChanged: (_) => flashMode.value = '0',
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Container(
//                     width: double.maxFinite,
//                     color: Pallet.secondaryColor,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 15,
//                     ),
//                     child: Text(
//                       'Lens Facing',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Semantics(
//                     identifier: 'lens_facing_back',
//                     label: 'Lens facing back',
//                     child: InkWell(
//                       onTap: () => lensFacing.value = '0',
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'BACK',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.black,
//                               ),
//                             ),
//                             Checkbox(
//                               value: lensFacing.value == '0',
//                               onChanged: (_) => lensFacing.value = '0',
//                               activeColor: Pallet.secondaryColor,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   Semantics(
//                     identifier: 'lens_facing_front',
//                     label: 'Lens facing front',
//                     child: InkWell(
//                       onTap: () => lensFacing.value = '1',
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'FRONT',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.black,
//                               ),
//                             ),
//                             Checkbox(
//                               value: lensFacing.value == '1',
//                               onChanged: (_) => lensFacing.value = '1',
//                               activeColor: Pallet.secondaryColor,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Container(
//                     width: double.maxFinite,
//                     color: Pallet.secondaryColor,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 15,
//                     ),
//                     child: Text(
//                       'Orientation',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Semantics(
//                     identifier: 'orientation_any',
//                     label: 'Orientation Any',
//                     child: InkWell(
//                       onTap: () => orientation.value = '0',
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'ANY',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.black,
//                               ),
//                             ),
//                             Checkbox(
//                               value: orientation.value == '0',
//                               activeColor: Pallet.secondaryColor,
//                               onChanged: (_) => orientation.value = '0',
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   Semantics(
//                     identifier: 'orientation_portrait',
//                     label: 'Orientation Portrait',
//                     child: InkWell(
//                       onTap: () => orientation.value = '1',
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'PORTRAIT',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.black,
//                               ),
//                             ),
//                             Checkbox(
//                               value: orientation.value == '1',
//                               activeColor: Pallet.secondaryColor,
//                               onChanged: (_) => orientation.value = '1',
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   Semantics(
//                     identifier: 'orientation_landscape_left',
//                     label: 'Orientation Landscape Left',
//                     child: InkWell(
//                       onTap: () => orientation.value = '2',
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'LANDSCAPE_LEFT',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.black,
//                               ),
//                             ),
//                             Checkbox(
//                               value: orientation.value == '2',
//                               activeColor: Pallet.secondaryColor,
//                               onChanged: (_) => orientation.value = '2',
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   Semantics(
//                     identifier: 'orientation_landscape_right',
//                     label: 'Orientation Landscape Right',
//                     child: InkWell(
//                       onTap: () => orientation.value = '3',
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'LANDSCAPE_RIGHT',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.black,
//                               ),
//                             ),
//                             Checkbox(
//                               value: orientation.value == '3',
//                               activeColor: Pallet.secondaryColor,
//                               onChanged: (_) => orientation.value = '3',
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   Semantics(
//                     identifier: 'orientation_portrait_reverse',
//                     label: 'Orientation Portrait Reverse',
//                     child: InkWell(
//                       onTap: () => orientation.value = '4',
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'PORTRAIT_REVERSE',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.black,
//                               ),
//                             ),
//                             Checkbox(
//                               value: orientation.value == '4',
//                               activeColor: Pallet.secondaryColor,
//                               onChanged: (_) => orientation.value = '4',
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(20),
//                     child: Semantics(
//                       identifier: 'open_camera',
//                       label: 'Open Camera',
//                       child: AppButton(
//                         text: 'Open Camera',
//                         backgroundColor: Pallet.secondaryColor,
//                         onTap: () => openSDKCamera(),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
