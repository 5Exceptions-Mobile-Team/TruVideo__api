import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_upload_sample_app/core/utils/utils.dart';
import 'package:video_compress/video_compress.dart' as video_info;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:intl/intl.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/core/services/web_media_storage_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:media_upload_sample_app/core/utils/blob_url_helper.dart';
import 'package:truvideo_camera_sdk/camera_configuration.dart';
import 'package:truvideo_camera_sdk/camera_mode.dart';
import 'package:truvideo_camera_sdk/truvideo_camera_sdk.dart';
import 'package:truvideo_camera_sdk/truvideo_sdk_camera_flash_mode.dart';
import 'package:truvideo_camera_sdk/truvideo_sdk_camera_lens_facing.dart';
import 'package:truvideo_camera_sdk/truvideo_sdk_camera_mode_type.dart';
import 'package:truvideo_camera_sdk/truvideo_sdk_camera_orientation.dart';
import 'package:truvideo_camera_sdk/truvideo_sdk_camera_media.dart';
import '../../common/widgets/error_widget.dart';
import '../../common/widgets/common_dialog.dart';
import '../widgets/loading_file_widget.dart';
import '../widgets/ios_file_picker_dialog.dart';
import '../widgets/add_file_dialog.dart';
import '../views/camera_configuration_screen.dart';
import '../../media_upload/views/media_upload_screen.dart';

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

  // Camera Configuration Reactive Variables
  Rx<TruvideoSdkCameraLensFacing> selectedLensFacing =
      TruvideoSdkCameraLensFacing.back.obs;
  Rx<TruvideoSdkCameraFlashMode> selectedFlashMode =
      TruvideoSdkCameraFlashMode.off.obs;
  Rx<TruvideoSdkCameraOrientation> selectedOrientation =
      TruvideoSdkCameraOrientation.portrait.obs;

  final WebMediaStorageService _webStorage = WebMediaStorageService();

  @override
  void onInit() {
    // Initialize default camera mode
    cameraMode ??= CameraModeEnum.videoAndImage;

    if (kIsWeb) {
      // Ensure web storage is initialized before loading media
      _webStorage
          .init()
          .then((_) {
            if (kDebugMode) {
              print(
                'GalleryController: Web storage initialized, loading media paths',
              );
            }
            getMediaPath();
          })
          .catchError((e) {
            if (kDebugMode) {
              print('GalleryController: Error initializing web storage: $e');
            }
          });
    } else {
      getMediaPath();
      requestPermission();
    }
    super.onInit();
  }

  Future<void> requestPermission() async {
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
          Permission.microphone,
        ].request();
      } else {
        /// Android 12 and below (API < 33)
        await [
          Permission.storage,
          Permission.camera,
          Permission.microphone,
        ].request();
      }
    } else if (Platform.isIOS) {
      await [
        Permission.photos,
        Permission.camera,
        Permission.microphone,
      ].request();
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
    if (tempCameraMode == null) {
      Utils.showToast('Please select a camera mode');
      return;
    }

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

    buildCameraMode();
    // Update both camera_mode and any listeners in configuration screen
    update(['camera_mode']);
    Get.back();
  }

  String getMediaType(String filePath) {
    // For web paths, get media type from stored item
    if (kIsWeb && filePath.startsWith('web_media_')) {
      final id = filePath.replaceFirst('web_media_', '');
      final mediaItem = _webStorage.getMediaItem(id);
      if (mediaItem != null) {
        return mediaItem.mediaType;
      }
      // Fallback: if item not found, return UNKNOWN
      return 'UNKNOWN';
    }

    // For file system paths, extract extension from path
    if (filePath.contains('.')) {
      final extension = filePath.split('.').last.toLowerCase();
      return _getMediaTypeFromExtension(extension);
    }
    return 'UNKNOWN';
  }

  // Supported file types according to TruVideo API docs
  static const List<String> supportedVideoExtensions = [
    'mp4',
    'mov',
    'avi',
    'mkv',
    'flv',
    'wmv',
    '3gpp',
    'webm',
  ];
  static const List<String> supportedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'svg',
  ];
  static const List<String> supportedAudioExtensions = [
    'mp3',
    'wav',
    'aac',
    'flac',
  ];
  static const List<String> supportedDocumentExtensions = ['pdf'];

  bool _isSupportedFileType(String extension) {
    final ext = extension.toLowerCase();
    return supportedVideoExtensions.contains(ext) ||
        supportedImageExtensions.contains(ext) ||
        supportedAudioExtensions.contains(ext) ||
        supportedDocumentExtensions.contains(ext);
  }

  String _getMediaTypeFromExtension(String extension) {
    final ext = extension.toLowerCase();
    if (supportedImageExtensions.contains(ext)) {
      return 'IMAGE';
    } else if (supportedVideoExtensions.contains(ext)) {
      return 'VIDEO';
    } else if (supportedAudioExtensions.contains(ext)) {
      return 'AUDIO';
    } else if (supportedDocumentExtensions.contains(ext)) {
      return 'DOCUMENT';
    } else {
      return 'UNKNOWN';
    }
  }

  void getMediaPath() async {
    try {
      // Clear existing paths first
      allMediaPaths.clear();
      imagePaths.clear();
      videoPaths.clear();
      audioPaths.clear();
      documentPaths.clear();

      if (kIsWeb) {
        // Load media from Hive storage for web
        if (!_webStorage.isInitialized) {
          await _webStorage.init();
        }

        final allMedia = _webStorage.getAllMedia();
        for (var mediaItem in allMedia) {
          final path = mediaItem.displayPath;
          if (mediaItem.mediaType == 'IMAGE') {
            if (!imagePaths.contains(path)) {
              imagePaths.add(path);
            }
          } else if (mediaItem.mediaType == 'VIDEO') {
            if (!videoPaths.contains(path)) {
              videoPaths.add(path);
            }
          } else if (mediaItem.mediaType == 'AUDIO') {
            if (!audioPaths.contains(path)) {
              audioPaths.add(path);
            }
          } else if (mediaItem.mediaType == 'DOCUMENT') {
            if (!documentPaths.contains(path)) {
              documentPaths.add(path);
            }
          }
        }
        _orderMediaByLatest();
        update(['update_media_list']);
      } else {
        // Mobile/Desktop: Use file system
        final directory = await getApplicationDocumentsDirectory();

        String galleryPath = '${directory.path}/gallery';

        final galleryDir = Directory(galleryPath);

        if (!await galleryDir.exists()) {
          await galleryDir.create(recursive: true);
        }

        if (await galleryDir.exists()) {
          galleryDir.listSync().forEach((file) {
            if (file is File &&
                !file.path.contains('thumbnail') &&
                !file.path.contains('edited')) {
              final extension = file.path.split('.').last.toLowerCase();
              final mediaType = _getMediaTypeFromExtension(extension);

              if (mediaType == 'IMAGE') {
                imagePaths.add(file.path);
              } else if (mediaType == 'VIDEO') {
                videoPaths.add(file.path);
              } else if (mediaType == 'AUDIO') {
                audioPaths.add(file.path);
              } else if (mediaType == 'DOCUMENT') {
                documentPaths.add(file.path);
              }
            }
          });
        }
        _orderMediaByLatest();
        update(['update_media_list']);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error on getting media path $e');
      }
    }
  }

  void updateMediaList(String path) async {
    // Get media type using the helper method which handles both web and file system paths
    final mediaType = getMediaType(path);

    if (mediaType == 'IMAGE' && !path.contains('thumbnail')) {
      if (!imagePaths.contains(path)) {
        imagePaths.add(path);
      }
    } else if (mediaType == 'VIDEO' && !path.contains('edited')) {
      if (!videoPaths.contains(path)) {
        videoPaths.add(path);
      }
    } else if (mediaType == 'AUDIO') {
      if (!audioPaths.contains(path)) {
        audioPaths.add(path);
      }
    } else if (mediaType == 'DOCUMENT') {
      if (!documentPaths.contains(path)) {
        documentPaths.add(path);
      }
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
        if (kIsWeb && path.startsWith('web_media_')) {
          // Web: Get from stored media item
          final id = path.replaceFirst('web_media_', '');
          final mediaItem = _webStorage.getMediaItem(id);
          if (mediaItem != null) {
            cache[path] = mediaItem.modifiedAt;
            return mediaItem.modifiedAt;
          }
        } else {
          // Mobile/Desktop: Use file system
          final value = File(path).lastModifiedSync();
          cache[path] = value;
          return value;
        }
      } catch (_) {
        // Fallback
      }
      final fallback = DateTime.fromMillisecondsSinceEpoch(0);
      cache[path] = fallback;
      return fallback;
    }

    paths.sort((a, b) => modified(b).compareTo(modified(a)));
  }

  Future<Widget> getLeadingWidget(String path, String type) async {
    if (kIsWeb && path.startsWith('web_media_')) {
      // Web: Load from Hive storage
      final id = path.replaceFirst('web_media_', '');
      if (type == 'IMAGE') {
        final bytes = await _webStorage.getMediaBytes(id);
        if (bytes != null) {
          return Image.memory(bytes, fit: BoxFit.cover);
        } else {
          return Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Pallet.secondaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.file_copy_rounded, size: 30),
          );
        }
      } else if (type == 'VIDEO') {
        // For web videos, generate thumbnail using BlobUrlHelper
        try {
          final bytes = await _webStorage.getMediaBytes(id);
          if (bytes != null) {
            final thumbnailBytes = await BlobUrlHelper.generateVideoThumbnail(
              bytes,
            );

            if (thumbnailBytes != null && thumbnailBytes.isNotEmpty) {
              return Image.memory(
                thumbnailBytes,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Pallet.secondaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.video_camera_front_rounded, size: 30),
                  );
                },
              );
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error generating web video thumbnail: $e');
          }
        }

        // Fallback to icon if thumbnail generation fails
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Pallet.secondaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.video_camera_front_rounded, size: 30),
        );
      } else if (type == 'AUDIO') {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Pallet.primaryColor.withOpacity(0.8),
                Pallet.primaryColor.withOpacity(0.6),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.music_note_rounded,
              color: Colors.white,
              size: 80,
            ),
          ),
        );
      } else if (type == 'DOCUMENT') {
        final isPdf = path.toLowerCase().endsWith('.pdf');
        return Container(
          decoration: BoxDecoration(color: const Color(0xFF6B7280)),
          child: Center(
            child: Icon(
              isPdf ? Icons.picture_as_pdf_rounded : Icons.description_rounded,
              color: Colors.white,
              size: 80,
            ),
          ),
        );
      } else {
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Pallet.secondaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.file_copy_rounded, size: 30),
        );
      }
    } else {
      // Mobile/Desktop: Use file system
      if (type == 'IMAGE') {
        return Image.file(File(path), fit: BoxFit.cover);
      } else if (type == 'VIDEO') {
        final thumbnailBytes = await VideoThumbnail.thumbnailData(
          video: path,
          maxWidth: 400,
          quality: 90,
        );

        if (thumbnailBytes != null) {
          return Image.memory(thumbnailBytes, fit: BoxFit.cover);
        } else {
          return Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Pallet.secondaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.video_camera_front_rounded, size: 30),
          );
        }
      } else if (type == 'AUDIO') {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Pallet.primaryColor.withOpacity(0.8),
                Pallet.primaryColor.withOpacity(0.6),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.music_note_rounded,
              color: Colors.white,
              size: 80,
            ),
          ),
        );
      } else if (type == 'DOCUMENT') {
        final isPdf = path.toLowerCase().endsWith('.pdf');
        return Container(
          decoration: BoxDecoration(color: const Color(0xFF6B7280)),
          child: Center(
            child: Icon(
              isPdf ? Icons.picture_as_pdf_rounded : Icons.description_rounded,
              color: Colors.white,
              size: 80,
            ),
          ),
        );
      } else {
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Pallet.secondaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.file_copy_rounded, size: 30),
        );
      }
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
      // User can open media for viewing or go to upload screen
      // For now, navigate to upload screen with the selected file
      try {
        Get.to(() => MediaUploadScreen(path: path));
      } catch (e) {
        if (kDebugMode) {
          print('Error while opening the file: $e');
        }
      }
    }
  }

  void enableDisableSelection() {
    selectedMedia.clear();
    selectEnabled.value = !selectEnabled.value;
  }

  void deleteMedia() async {
    if (selectedMedia.isEmpty) {
      Utils.showToast('Please select media');
      return;
    }

    // Show confirmation dialog
    Get.dialog(
      CommonDialog(
        title: 'Delete Media',
        content:
            'Are you sure you want to delete ${selectedMedia.length} item(s)?',
        onConfirm: () async {
          Get.back(); // Close dialog

          if (kIsWeb) {
            // Web: Delete from Hive storage
            List<Future> futures = [];
            for (String path in selectedMedia) {
              if (path.startsWith('web_media_')) {
                final id = path.replaceFirst('web_media_', '');
                futures.add(_webStorage.deleteMedia(id));
              }
            }
            await Future.wait(futures);
          } else {
            // Mobile/Desktop: Delete from file system
            List<Future> futures = [];
            for (String path in selectedMedia) {
              final file = File(path);
              futures.add(file.delete());
            }
            await Future.wait(futures);
          }
          // Clear selection before refreshing
          selectedMedia.clear();
          allMediaPaths.clear();
          imagePaths.clear();
          videoPaths.clear();
          audioPaths.clear();
          documentPaths.clear();
          selectEnabled.value = false;
          getMediaPath();
          Utils.showToast('Media deleted successfully');
        },
      ),
    );
  }

  void showLoadingDialog() async {
    await Future.delayed(const Duration(milliseconds: 300));
    Get.dialog(LoadingFileWidget(), barrierDismissible: false);
  }

  void pickFile() async {
    // For mobile (Android/iOS), show dialog to choose between SDK Camera and Pick File
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      Get.dialog(
        AddFileDialog(
          onSdkCamera: () {
            Get.to(() => const CameraConfigurationScreen());
          },
          onPickFile: () {
            // For iOS, show the existing iOS file picker dialog
            if (Platform.isIOS) {
              // Close AddFileDialog first, then show iOS picker dialog
              // Get.back();
              Get.dialog(
                IosFilePickerDialog(
                  onPickPhotosVideo: () => _pickPhotosVideo(),
                  onPickAudioDocument: () => _pickAudioDocument(),
                ),
              );
            } else {
              // For Android, proceed with normal file picking
              _pickFileDirectly();
            }
          },
        ),
      );
      return;
    }

    // For web, proceed with normal file picking
    _pickFileDirectly();
  }

  /// Direct file picking (used for web and Android)
  Future<void> _pickFileDirectly() async {
    try {
      showLoadingDialog();

      FilePickerResult? result;

      if (kIsWeb) {
        result = await FilePicker.platform.pickFiles(
          withData: kIsWeb, // Need data for web
        );
      } else {
        // Combine all supported extensions
        final allSupportedExtensions = [
          ...supportedVideoExtensions,
          ...supportedImageExtensions,
          ...supportedAudioExtensions,
          ...supportedDocumentExtensions,
        ];

        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          withData: kIsWeb, // Need data for web
          allowedExtensions: allSupportedExtensions,
        );
      }

      if (result != null) {
        final file = result.files.single;
        final fileName = file.name;
        final extension = fileName.split('.').last.toLowerCase();

        // Validate file type
        if (!_isSupportedFileType(extension)) {
          Get.back(); // Close loading dialog
          Get.dialog(
            ErrorDialog(
              title: 'Unsupported File Type',
              subTitle:
                  'This file type is not supported. Please choose a video, image, audio, or PDF file.\n\nSupported formats:\n• Videos: MP4, MOV, AVI, MKV, FLV, WMV, 3GPP, WEBM\n• Images: JPG, JPEG, PNG, SVG\n• Audio: MP3, WAV, AAC, FLAC\n• Documents: PDF',
            ),
          );
          return;
        }

        if (kIsWeb) {
          // Web: Store file bytes in Hive
          if (file.bytes != null) {
            // Determine media type from file name extension
            final mediaType = _getMediaTypeFromExtension(extension);

            final displayPath = await _webStorage.saveMedia(
              fileName: fileName,
              mediaType: mediaType,
              fileBytes: file.bytes!,
            );

            // Immediately update the media list with the new file
            updateMediaList(displayPath);
          }
          Get.back();
        } else {
          // Mobile/Desktop: Use file system
          final dir = await getApplicationDocumentsDirectory();
          String galleryPath = '${dir.path}/gallery';

          final galleryDir = Directory(galleryPath);

          if (!galleryDir.existsSync()) {
            await galleryDir.create(recursive: true);
          }

          File fileObj = File(result.files.single.path!);
          String newPath = '$galleryPath/$fileName';
          try {
            await fileObj.rename(newPath);
          } catch (e) {
            await fileObj.copy(newPath);
          }
          updateMediaList(newPath);
          Get.back();
        }
      } else {
        Get.back();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error on picking file: $e');
      }
      Get.back();
    }
  }

  /// iOS-only: Pick photos or videos
  Future<void> _pickPhotosVideo() async {
    try {
      showLoadingDialog();

      final result = await FilePicker.platform.pickFiles(type: FileType.media);

      if (result != null) {
        await _handlePickedFile(result);
      } else {
        Get.back();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error on picking photos/video: $e');
      }
      Get.back();
    }
  }

  /// iOS-only: Pick audio or documents
  Future<void> _pickAudioDocument() async {
    try {
      showLoadingDialog();

      // Combine audio and document extensions
      final audioDocumentExtensions = [
        ...supportedAudioExtensions,
        ...supportedDocumentExtensions,
      ];

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: audioDocumentExtensions,
      );

      if (result != null) {
        await _handlePickedFile(result);
      } else {
        Get.back();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error on picking audio/document: $e');
      }
      Get.back();
    }
  }

  /// Handle the picked file (common logic for both iOS picker types)
  Future<void> _handlePickedFile(FilePickerResult result) async {
    final file = result.files.single;
    final fileName = file.name;
    final extension = fileName.split('.').last.toLowerCase();

    // Validate file type
    if (!_isSupportedFileType(extension)) {
      Get.back(); // Close loading dialog
      Get.dialog(
        ErrorDialog(
          title: 'Unsupported File Type',
          subTitle:
              'This file type is not supported. Please choose a video, image, audio, or PDF file.\n\nSupported formats:\n• Videos: MP4, MOV, AVI, MKV, FLV, WMV, 3GPP, WEBM\n• Images: JPG, JPEG, PNG, SVG\n• Audio: MP3, WAV, AAC, FLAC\n• Documents: PDF',
        ),
      );
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    String galleryPath = '${dir.path}/gallery';

    final galleryDir = Directory(galleryPath);

    if (!galleryDir.existsSync()) {
      await galleryDir.create(recursive: true);
    }

    File fileObj = File(result.files.single.path!);
    String newPath = '$galleryPath/$fileName';

    await fileObj.copy(newPath);
    await File(newPath).setLastModified(DateTime.now());

    updateMediaList(newPath);
    Get.back();
  }

  Future<void> openSdkCamera() async {
    await requestPermission();
    // if (!await Permission.camera.isGranted &&
    //     !await Permission.microphone.isGranted) {
    //   Utils.showToast('Please grant Camera and Microphone permission');
    //   return;
    // }
    try {
      // Get gallery path
      final dir = await getApplicationDocumentsDirectory();
      String galleryPath = '${dir.path}/gallery';

      final galleryDir = Directory(galleryPath);
      if (!galleryDir.existsSync()) {
        await galleryDir.create(recursive: true);
      }

      // Build CameraConfiguration
      final config = CameraConfiguration(
        lensFacing: selectedLensFacing.value,
        flashMode: selectedFlashMode.value,
        orientation: selectedOrientation.value,
        outputPath: galleryPath,
        mode: getCameraMode(),
      );

      // Open camera
      List<TruvideoSdkCameraMedia> result = await TruvideoCameraSdk.openCamera(
        configuration: config,
      );

      // Close camera configuration screen if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      // Navigate back from camera configuration screen
      Get.back();

      // Handle results
      await handleCameraResults(result, galleryPath);

      // Refresh media list
      getMediaPath();
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Camera opening failed: $e');
      }
      Get.dialog(
        ErrorDialog(
          title: 'Camera Error',
          subTitle: e.message ?? 'Failed to open camera',
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Camera opening failed: $e');
      }
      Get.dialog(
        ErrorDialog(
          title: 'Camera Error',
          subTitle: 'Failed to open camera. Please try again.',
        ),
      );
    }
  }

  Future<void> handleCameraResults(
    List<TruvideoSdkCameraMedia> results,
    String galleryPath,
  ) async {
    if (results.isEmpty) {
      return;
    }

    // Reset camera mode after successful capture
    cameraMode = null;
    videoCount = null;
    imageCount = null;
    mediaCount = null;
    videoDuration = null;

    for (var media in results) {
      String filePath = media.filePath;

      // For Android or MP4 files, copy/move to gallery directory
      if (Platform.isAndroid ||
          filePath.split('.').last.toLowerCase() == 'mp4') {
        final File originalFile = File(filePath);
        final String fileName = filePath.split('/').last;
        final String targetPath = '$galleryPath/$fileName';

        try {
          // Try to move file first
          await originalFile.rename(targetPath);
        } catch (e) {
          // If move fails, copy and delete original
          await originalFile.copy(targetPath);
          try {
            await originalFile.delete();
          } catch (_) {
            // Ignore delete errors
          }
        }

        updateMediaList(targetPath);
      } else {
        // For iOS, file is already in the correct location
        updateMediaList(filePath);
      }
    }

    // Refresh gallery
    update(['update_media_list']);
  }

  void changeCameraMode(CameraModeEnum selectedMode) {
    tempCameraMode = selectedMode;
    tempVideoCount = null;
    tempImageCount = null;
    tempMediaCount = null;
    tempVideoDuration = null;
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
      // Default: videoAndImage
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
      if (kIsWeb && path.startsWith('web_media_')) {
        // Web: Get metadata from stored media item
        final id = path.replaceFirst('web_media_', '');
        final mediaItem = _webStorage.getMediaItem(id);

        if (mediaItem == null) return null;

        String metadata = '';
        String creationDate = '';

        if (mediaItem.mediaType == 'IMAGE') {
          final bytes = await _webStorage.getMediaBytes(id);
          if (bytes != null) {
            try {
              // For web, we'll use file size as metadata since image_size_getter
              // doesn't easily support memory input on web
              metadata = 'Size: ${_formatBytes(mediaItem.fileSize)}';
            } catch (e) {
              metadata = 'Size: ${_formatBytes(mediaItem.fileSize)}';
            }
          }
        } else if (mediaItem.mediaType == 'VIDEO') {
          metadata = 'Size: ${_formatBytes(mediaItem.fileSize)}';
        } else {
          metadata = 'Size: ${_formatBytes(mediaItem.fileSize)}';
        }

        creationDate = formatDate(mediaItem.createdAt.toString());
        return (metadata, creationDate);
      } else {
        // Mobile/Desktop: Use file system
        final extension = path.toLowerCase().split('.').last;
        final isImage = [
          'jpg',
          'jpeg',
          'png',
          'heic',
          'heif',
        ].contains(extension);
        final isVideo = ['mp4', 'mkv', 'mov', 'webm'].contains(extension);

        String metadata = '';
        String creationDate = '';

        if (isImage) {
          final res = ImageSizeGetter.getSizeResult(FileInput(File(path)));
          metadata = 'Resolution: ${res.size.width}x${res.size.height}';
        } else if (isVideo) {
          // final mediaInfo = MediaInfo();
          // final info = await mediaInfo.getMediaInfo(path);
          //
          // final durationMs = info['durationMs'] as int?;
          //
          // final duration = Duration(milliseconds: durationMs ?? 0);
          // metadata = 'Duration: ${duration.toString().split('.').first}';

          final info = await video_info.VideoCompress.getMediaInfo(path);
          final durationMs = info.duration;

          final duration = Duration(milliseconds: durationMs?.toInt() ?? 0);
          metadata = 'Duration: ${duration.toString().split('.').first}';
        }
        creationDate = await getFileCreationTime(path);
        return (metadata, creationDate);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error reading metadata: $e');
      }
      return null;
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  Future<String> getFileCreationTime(String path) async {
    if (kIsWeb && path.startsWith('web_media_')) {
      // Web: Get from stored media item
      final id = path.replaceFirst('web_media_', '');
      final mediaItem = _webStorage.getMediaItem(id);
      if (mediaItem != null) {
        return formatDate(mediaItem.createdAt.toString());
      }
      return '';
    } else {
      // Mobile/Desktop: Use file system
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
