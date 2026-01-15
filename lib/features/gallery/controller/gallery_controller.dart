import 'dart:async';
import 'dart:io';
import 'dart:math';
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
import 'package:get_thumbnail_video/video_thumbnail.dart' as get_thumbnail;
import 'package:media_upload_sample_app/core/utils/blob_url_helper.dart';
import '../../common/widgets/error_widget.dart';
import '../../common/widgets/common_dialog.dart';
import '../widgets/loading_file_widget.dart';
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

  final WebMediaStorageService _webStorage = WebMediaStorageService();

  @override
  void onInit() {
    if (kIsWeb) {
      // Ensure web storage is initialized before loading media
      _webStorage.init().then((_) {
        if (kDebugMode) {
          print('GalleryController: Web storage initialized, loading media paths');
        }
        getMediaPath();
      }).catchError((e) {
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
          // Permission.camera,
        ].request();
      } else {
        /// Android 12 and below (API < 33)
        await [
          Permission.storage,
          // Permission.camera
        ].request();
      }
    } else if (Platform.isIOS) {
      await [
        Permission.photos,
        // Permission.camera
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
  static const List<String> supportedDocumentExtensions = [
    'pdf',
  ];

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
            if (file is File && !file.path.contains('thumbnail') && !file.path.contains('edited')) {
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
        // For web videos, generate thumbnail using get_thumbnail_video
        try {
          final bytes = await _webStorage.getMediaBytes(id);
          if (bytes != null) {
            // Create blob URL from bytes for get_thumbnail_video
            String? blobUrl;
            try {
              blobUrl = BlobUrlHelper.createBlobUrl(bytes);
              
              // Use get_thumbnail_video for web video thumbnails
              final thumbnailBytes = await get_thumbnail.VideoThumbnail.thumbnailData(
                video: blobUrl,
                maxWidth: 400,
                quality: 90,
              );
              
              if (thumbnailBytes.isNotEmpty) {
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
            } finally {
              // Clean up blob URL
              if (blobUrl != null) {
                BlobUrlHelper.revokeBlobUrl(blobUrl);
              }
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
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Pallet.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.audiotrack_rounded, size: 30, color: Pallet.primaryColor),
        );
      } else if (type == 'DOCUMENT') {
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Pallet.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.description_rounded, size: 30, color: Pallet.primaryColor),
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
          return Image.memory(
            thumbnailBytes,
            fit: BoxFit.cover,
          );
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
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Pallet.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.audiotrack_rounded, size: 30, color: Pallet.primaryColor),
        );
      } else if (type == 'DOCUMENT') {
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Pallet.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.description_rounded, size: 30, color: Pallet.primaryColor),
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
          type: Platform.isIOS ? FileType.media : FileType.custom,
          withData: kIsWeb, // Need data for web
          allowedExtensions: Platform.isIOS ? null : allSupportedExtensions,
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
        } else if (Platform.isIOS) {
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

  // Future<void> openCamera(CameraConfiguration config, String path) async {
  //   try {
  //     List<TruvideoSdkCameraMedia> result = await TruvideoCameraSdk.openCamera(
  //       configuration: config,
  //     );
  //     Get.back();
  //
  //     if (result.isNotEmpty) {
  //       cameraMode = null;
  //     }
  //
  //     for (var e in result) {
  //       if (Platform.isAndroid || e.filePath.split('.').last == 'mp4') {
  //         String filePath = e.filePath;
  //         final File originalFile = File(filePath);
  //         final String fileName = mPath.basename(filePath);
  //         final String targetPath = mPath.join(path, fileName);
  //         try {
  //           await originalFile.rename(targetPath);
  //         } catch (e) {
  //           await originalFile.copy(targetPath);
  //           originalFile.delete();
  //         }
  //
  //         updateMediaList(targetPath);
  //       } else {
  //         updateMediaList(e.filePath);
  //       }
  //     }
  //   } on PlatformException catch (e) {
  //     if (kDebugMode) {
  //       print('Camera opening failed: $e');
  //     }
  //     Get.dialog(ErrorDialog(title: 'Error', subTitle: e.message));
  //   }
  // }

  // void changeCameraMode(CameraModeEnum selectedMode) {
  //   tempCameraMode = selectedMode;
  //   videoCount = null;
  //   imageCount = null;
  //   mediaCount = null;
  //   videoDuration = null;
  //   update(['camera_mode']);
  // }

  // CameraMode getCameraMode() {
  //   if (cameraMode == CameraModeEnum.video) {
  //     return CameraMode.video(
  //       videoMaxCount: videoCount,
  //       durationLimit: videoDuration,
  //     );
  //   } else if (cameraMode == CameraModeEnum.image) {
  //     return CameraMode.image(imageMaxCount: imageCount);
  //   } else if (cameraMode == CameraModeEnum.singleVideo) {
  //     return CameraMode.singleVideo(durationLimit: videoDuration);
  //   } else if (cameraMode == CameraModeEnum.singleImage) {
  //     return CameraMode.singleImage();
  //   } else if (cameraMode == CameraModeEnum.singleMedia) {
  //     return CameraMode.singleMedia(
  //       mediaCount: mediaCount,
  //       durationLimit: videoDuration,
  //     );
  //   } else if (cameraMode == CameraModeEnum.singleVideoAndImage) {
  //     return CameraMode.singleVideoOrImage(durationLimit: videoDuration);
  //   } else {
  //     return CameraMode.videoAndImage(
  //       videoMaxCount: videoCount,
  //       imageMaxCount: imageCount,
  //       durationLimit: videoDuration,
  //     );
  //   }
  // }

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
