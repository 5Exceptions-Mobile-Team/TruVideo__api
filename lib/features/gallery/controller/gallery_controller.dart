import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:audio_info/audio_info.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_info/flutter_file_info.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:intl/intl.dart';
import 'package:media_info/media_info.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:truvideo_camera_sdk/ar_camera_configuration.dart';
import 'package:truvideo_camera_sdk/camera_configuration.dart';
import 'package:truvideo_camera_sdk/camera_mode.dart';
import 'package:truvideo_camera_sdk/truvideo_camera_sdk.dart';
import 'package:truvideo_camera_sdk/truvideo_sdk_camera_media.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path/path.dart' as mPath;

import '../../common/widgets/error_widget.dart';
import '../widgets/loading_file_widget.dart';

enum CameraModeEnum {
  videoAndImage,
  video,
  image,
  singleVideo,
  singleImage,
  singleMedia,
  singleVideoAndImage,
}

class GalleryController extends GetxController {
  List<String> allMediaPaths = [];
  List<String> imagePaths = [];
  List<String> videoPaths = [];
  List<String> audioPaths = [];
  List<String> documentPaths = [];
  GetStorage storage = GetStorage();

  bool autoClose = false;
  RxBool selectEnabled = false.obs;
  RxList selectedMedia = [].obs;

  CameraModeEnum? tempCameraMode;
  CameraModeEnum? cameraMode;

  List<String> pickedFilePaths = [];

  int? tempVideoCount;
  int? tempImageCount;
  int? tempMediaCount;
  int? tempVideoDuration;

  int? videoCount;
  int? imageCount;
  int? mediaCount;
  int? videoDuration;

  @override
  void onInit() {
    getMediaPath();
    requestPermission();
    super.onInit();
  }

  void requestPermission() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      int sdkInt = androidInfo.version.sdkInt;

      /// Android 13+ (API 33+)
      if (sdkInt >= 33) {
        await [
          Permission.photos,
          Permission.videos,
          Permission.audio,
          Permission.camera,
        ].request();
      } else {
        /// Android 12 and below (API < 33)
        await [Permission.storage, Permission.camera].request();
      }
    } else if (Platform.isIOS) {
      await [Permission.photos, Permission.camera].request();
    }
  }

  void buildCameraMode() {
    tempCameraMode = null;
    if (cameraMode == CameraModeEnum.singleImage ||
        cameraMode == CameraModeEnum.singleVideo ||
        cameraMode == CameraModeEnum.singleVideoAndImage) {
      autoClose = true;
    } else {
      autoClose = false;
    }
    update(['camera_mode']);
  }

  void updateCameraModeLimits() {
    if (tempVideoDuration != null &&
        int.parse(tempVideoDuration.toString()) < 1000) {
      Get.dialog(
        ErrorDialog(
          title: 'Invalid duration',
          subTitle:
              'Video duration should be at least 1000 milliseconds (Minimum of 1 Second)',
        ),
      );
      return;
    }

    cameraMode = tempCameraMode;
    videoCount = tempVideoCount;
    imageCount = tempImageCount;
    mediaCount = tempMediaCount;
    videoDuration = tempVideoDuration;

    tempCameraMode = null;
    tempVideoCount = null;
    tempImageCount = null;
    tempMediaCount = null;
    tempVideoDuration = null;
    Get.back();
  }

  String getMediaType(String filePath) {
    if ([
      'png',
      'jpeg',
      'jpg',
    ].contains(filePath.split('.').last.toLowerCase())) {
      return 'IMAGE';
    } else if ([
      'mp4',
      'mov',
      'mkv',
      'webm',
    ].contains(filePath.split('.').last.toLowerCase())) {
      return 'VIDEO';
    } else if ([
      'mp3',
      'aac',
      'wav',
      'm4a',
    ].contains(filePath.split('.').last.toLowerCase())) {
      return 'AUDIO';
    } else if ([
      'pdf',
      'doc',
      'docx',
      'txt',
    ].contains(filePath.split('.').last.toLowerCase())) {
      return 'DOCUMENT';
    } else {
      return 'UNKNOWN';
    }
  }

  void getMediaPath() async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      String galleryPath = '${directory.path}/gallery';

      final galleryDir = Directory(galleryPath);

      if (!await galleryDir.exists()) {
        await galleryDir.create(recursive: true);
      }

      if (await galleryDir.exists()) {
        galleryDir.listSync().forEach((file) {
          if (file is File &&
              [
                'png',
                'jpeg',
                'jpg',
              ].contains(file.path.split('.').last.toLowerCase()) &&
              !file.path.contains('thumbnail')) {
            imagePaths.add(file.path);
          } else if (file is File &&
              [
                'mp4',
                'mov',
                'mkv',
                'webm',
              ].contains(file.path.split('.').last.toLowerCase()) &&
              !file.path.contains('edited')) {
            videoPaths.add(file.path);
          }
        });
      }
      _orderMediaByLatest();

      update(['update_media_list']);
    } catch (e) {
      print('Error on getting media path $e');
    }
  }

  void updateMediaList(String path) async {
    if (['png', 'jpeg', 'jpg'].contains(path.split('.').last.toLowerCase()) &&
        !path.contains('thumbnail')) {
      imagePaths.add(path);
    } else if ([
          'mp4',
          'mov',
          'mkv',
          'webm',
        ].contains(path.split('.').last.toLowerCase()) &&
        !path.contains('edited')) {
      videoPaths.add(path);
    }
    _orderMediaByLatest();
    update(['update_media_list']);
  }

  /// mediaType 0 = all, 1 = image, 2 = video, 3 = audio, 4 = docs
  List<String> getMediaList(String mediaType) {
    switch (mediaType) {
      case '1':
        return imagePaths;
      case '2':
        return videoPaths;
      case '3':
        return audioPaths;
      case '4':
        return documentPaths;

      default: // 0
        return allMediaPaths;
    }
  }

  void _orderMediaByLatest() {
    _sortPathsByModified(imagePaths);
    _sortPathsByModified(videoPaths);
    _sortPathsByModified(audioPaths);
    _sortPathsByModified(documentPaths);

    allMediaPaths
      ..clear()
      ..addAll(imagePaths)
      ..addAll(videoPaths)
      ..addAll(audioPaths)
      ..addAll(documentPaths);

    _sortPathsByModified(allMediaPaths);
  }

  void _sortPathsByModified(List<String> paths) {
    final cache = <String, DateTime>{};

    DateTime modified(String path) {
      if (cache.containsKey(path)) {
        return cache[path]!;
      }
      try {
        final value = File(path).lastModifiedSync();
        cache[path] = value;
        return value;
      } catch (_) {
        final fallback = DateTime.fromMillisecondsSinceEpoch(0);
        cache[path] = fallback;
        return fallback;
      }
    }

    paths.sort((a, b) => modified(b).compareTo(modified(a)));
  }

  Future<Widget> getLeadingWidget(String path, String type) async {
    if (type == 'IMAGE') {
      return Image.file(File(path), height: 45, width: 45);
    } else if (type == 'VIDEO') {
      final thumbnailBytes = await VideoThumbnail.thumbnailData(
        video: path,
        maxWidth: 300,
        quality: 20,
      );

      if (thumbnailBytes != null) {
        return Image.memory(thumbnailBytes, height: 45, width: 45);
      } else {
        return Container(
          height: 45,
          width: 45,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Pallet.secondaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.video_camera_front_rounded, size: 30),
        );
      }
    } else {
      return Container(
        height: 45,
        width: 45,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Pallet.secondaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.file_copy_rounded, size: 30),
      );
    }
  }

  void openOrSelect(String path) async {
    if (selectEnabled.value) {
      if (selectedMedia.contains(path)) {
        selectedMedia.remove(path);
      } else {
        selectedMedia.add(path);
      }
    } else {
      try {
        await OpenFilex.open(path);
      } catch (e) {
        print('Error while opening the file: $e');
      }
    }
  }

  void enableDisableSelection() {
    selectedMedia.clear();
    selectEnabled.value = !selectEnabled.value;
  }

  void deleteMedia() async {
    List<Future> futures = [];
    for (String path in selectedMedia) {
      final file = File(path);
      futures.add(file.delete());
    }
    await Future.wait(futures);
    allMediaPaths.clear();
    imagePaths.clear();
    videoPaths.clear();
    audioPaths.clear();
    documentPaths.clear();
    selectEnabled.value = false;
    getMediaPath();
  }

  void showLoadingDialog() async {
    await Future.delayed(const Duration(milliseconds: 300));
    Get.dialog(LoadingFileWidget(), barrierDismissible: false);
  }

  void pickFile() async {
    try {
      showLoadingDialog();

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        withData: false,
      );

      if (result != null) {
        final dir = await getApplicationDocumentsDirectory();
        String galleryPath = '${dir.path}/gallery';

        final galleryDir = Directory(galleryPath);

        if (!galleryDir.existsSync()) {
          await galleryDir.create(recursive: true);
        }

        File file = File(result.files.single.path!);
        String newPath = '$galleryPath/${result.files.single.name}';
        try {
          await file.rename(newPath);
        } catch (e) {
          await file.copy(newPath);
        }
        updateMediaList(newPath);
        Get.back();
      } else {
        Get.back();
      }
    } catch (e) {
      print('Error on picking file: $e');
    }
  }

  Future<void> openCamera(CameraConfiguration config, String path) async {
    try {
      List<TruvideoSdkCameraMedia> result = await TruvideoCameraSdk.openCamera(
        configuration: config,
      );
      Get.back();

      if (result.isNotEmpty) {
        cameraMode = null;
      }

      for (var e in result) {
        if (Platform.isAndroid || e.filePath.split('.').last == 'mp4') {
          String filePath = e.filePath;
          final File originalFile = File(filePath);
          final String fileName = mPath.basename(filePath);
          final String targetPath = mPath.join(path, fileName);
          try {
            await originalFile.rename(targetPath);
          } catch (e) {
            await originalFile.copy(targetPath);
            originalFile.delete();
          }

          updateMediaList(targetPath);
        } else {
          updateMediaList(e.filePath);
        }
      }
    } on PlatformException catch (e) {
      print('Camera opening failed: $e');
      Get.dialog(ErrorDialog(title: 'Error', subTitle: e.message));
    }
  }

  void changeCameraMode(CameraModeEnum selectedMode) {
    tempCameraMode = selectedMode;
    videoCount = null;
    imageCount = null;
    mediaCount = null;
    videoDuration = null;
    update(['camera_mode']);
  }

  CameraMode getCameraMode() {
    if (cameraMode == CameraModeEnum.video) {
      return CameraMode.video(
        videoMaxCount: videoCount,
        durationLimit: videoDuration,
      );
    } else if (cameraMode == CameraModeEnum.image) {
      return CameraMode.image(imageMaxCount: imageCount);
    } else if (cameraMode == CameraModeEnum.singleVideo) {
      return CameraMode.singleVideo(durationLimit: videoDuration);
    } else if (cameraMode == CameraModeEnum.singleImage) {
      return CameraMode.singleImage();
    } else if (cameraMode == CameraModeEnum.singleMedia) {
      return CameraMode.singleMedia(
        mediaCount: mediaCount,
        durationLimit: videoDuration,
      );
    } else if (cameraMode == CameraModeEnum.singleVideoAndImage) {
      return CameraMode.singleVideoOrImage(durationLimit: videoDuration);
    } else {
      return CameraMode.videoAndImage(
        videoMaxCount: videoCount,
        imageMaxCount: imageCount,
        durationLimit: videoDuration,
      );
    }
  }

  Future<(String metadata, String creationDate)?> getMediaMetadata(
    String path,
  ) async {
    try {
      final extension = path.toLowerCase().split('.').last;
      final isImage = ['jpg', 'jpeg', 'png'].contains(extension);
      final isVideo = ['mp4', 'mkv', 'mov', 'webm'].contains(extension);
      final isAudio = ['mp3', 'aac', 'wav', 'm4a'].contains(extension);

      String metadata = '';
      String creationDate = '';

      if (isImage) {
        final res = ImageSizeGetter.getSizeResult(FileInput(File(path)));
        metadata = 'Resolution: ${res.size.width}x${res.size.height}';
      } else if (isVideo) {
        final mediaInfo = MediaInfo();
        final info = await mediaInfo.getMediaInfo(path);

        final durationMs = info['durationMs'] as int?;

        final duration = Duration(milliseconds: durationMs ?? 0);
        metadata = 'Duration: ${duration.toString().split('.').first}';
      }
      creationDate = await getFileCreationTime(path);
      return (metadata, creationDate);
    } catch (e) {
      print('Error reading metadata: $e');
      return null;
    }
  }

  Future<String> getFileCreationTime(String path) async {
    FileMetadata? fileMetadata = await FileInfo.instance.getFileInfo(path);

    final data = fileMetadata?.creationTime;

    if (data != null) {
      return formatDate(data.toString());
    } else {
      final fileStat = await File(path).stat();
      return formatDate(fileStat.modified.toString());
    }
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) {
      return '';
    }

    final time = DateTime.tryParse(date);
    if (time != null) {
      return DateFormat('MMM dd yyyy h:mm a').format(time);
    }
    return '';
  }
}
