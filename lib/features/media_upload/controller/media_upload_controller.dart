import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:dio/dio.dart' hide Response;
import 'package:dio/dio.dart' as dio show Response;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:media_upload_sample_app/core/resourses/endpoints.dart';
import 'package:media_upload_sample_app/core/services/api_service.dart';
import 'package:media_upload_sample_app/core/services/connectivity_service.dart';
import 'package:media_upload_sample_app/core/services/web_media_storage_service.dart';
import 'package:media_upload_sample_app/core/utils/utils.dart';
import 'package:media_upload_sample_app/features/common/widgets/error_widget.dart';
import 'package:media_upload_sample_app/features/gallery/controller/gallery_controller.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class MediaUploadController extends GetxController {
  GetStorage storage = GetStorage();
  final String filePath;

  MediaUploadController(this.filePath);

  // Constants
  static const int _minFileSizeForMultipartMB = 10;
  static const int _minPartSizeMB = 5;
  static const String _boTokenKey = 'bo_token';

  late TextEditingController titleController;
  late TextEditingController creatorController;
  late TextEditingController metadataController;

  RxList<Map<String, TextEditingController>> tagControllers =
      <Map<String, TextEditingController>>[].obs;

  late GalleryController galleryController;
  final WebMediaStorageService _webStorage = WebMediaStorageService();

  RxString mediaType = ''.obs;
  RxString fileSize = ''.obs;
  RxInt sizeInBytes = 0.obs;
  RxString duration = '0'.obs;
  RxString resolution = 'NORMAL'.obs;

  RxBool isLoading = false.obs;
  Rx<Uint8List?> thumbnailBytes = Rx<Uint8List?>(null);

  // Stepper state management for 3 API steps
  RxInt currentStep = 0.obs; // 0: Initialize, 1: Upload, 2: Finalize
  RxBool isInitializeComplete = false.obs;
  RxBool isUploadComplete = false.obs;
  RxBool isFinalizeComplete = false.obs;
  RxBool isStepLoading = false.obs;

  // Upload progress tracking
  RxInt currentUploadPart = 0.obs; // Current part being uploaded (1-based)
  RxInt totalUploadParts = 1.obs; // Total number of parts
  RxDouble uploadProgress = 0.0.obs; // Progress percentage (0.0 to 100.0)

  // API Response storage for display
  Rx<Map<String, dynamic>?> initializeResponse = Rx<Map<String, dynamic>?>(
    null,
  );
  Rx<Map<String, dynamic>?> uploadResponse = Rx<Map<String, dynamic>?>(null);
  Rx<Map<String, dynamic>?> finalizeResponse = Rx<Map<String, dynamic>?>(null);

  // API Request payload storage for display
  Rx<Map<String, dynamic>?> initializePayload = Rx<Map<String, dynamic>?>(null);
  Rx<Map<String, dynamic>?> uploadPayload = Rx<Map<String, dynamic>?>(null);
  Rx<Map<String, dynamic>?> finalizePayload = Rx<Map<String, dynamic>?>(null);

  // Store upload response headers (for multipart uploads)
  List<Map<String, dynamic>> uploadResponseHeaders = [];

  // Checkbox options
  RxBool isLibrary = false.obs;
  RxBool includeInReport = false.obs;

  // Number of parts for file upload
  RxInt numberOfParts = 1.obs;

  // API Response storage
  String? uploadId;
  String? uploadPresignedUrl; // For backward compatibility (single part)
  List<Map<String, dynamic>> uploadParts = []; // For multipart uploads
  String? etag; // For backward compatibility (single part)
  List<Map<String, String>> uploadedParts =
      []; // List of {etag, partNumber} for multipart uploads

  @override
  void onInit() {
    titleController = TextEditingController();
    _addInitialTagRow();
    metadataController = TextEditingController();
    creatorController = TextEditingController();
    galleryController = Get.find<GalleryController>();
    _initializeMediaInfo();
    super.onInit();
  }

  @override
  void onClose() {
    titleController.dispose();
    metadataController.dispose();
    creatorController.dispose();
    for (var controllers in tagControllers) {
      controllers['key']?.dispose();
      controllers['value']?.dispose();
    }
    super.onClose();
  }

  void _addInitialTagRow() {
    tagControllers.add({
      'key': TextEditingController(),
      'value': TextEditingController(),
    });
  }

  void addTagRow() {
    tagControllers.add({
      'key': TextEditingController(),
      'value': TextEditingController(),
    });
  }

  void removeLastTagRow() {
    if (tagControllers.length > 1) {
      var last = tagControllers.removeLast();
      last['key']?.dispose();
      last['value']?.dispose();
    }
  }

  // Helper: Get file size in MB
  double _getFileSizeInMB() => sizeInBytes.value / (1024 * 1024);

  // Get maximum allowed parts based on file size (each part must be at least 5MB)
  int getMaxAllowedParts() {
    if (sizeInBytes.value == 0) return 1;
    final fileSizeInMB = _getFileSizeInMB();
    if (fileSizeInMB < _minFileSizeForMultipartMB) return 1;
    return (fileSizeInMB / _minPartSizeMB).floor();
  }

  // Check if multipart upload is allowed for current file size
  bool isMultipartAllowed() {
    if (sizeInBytes.value == 0) return false;
    return _getFileSizeInMB() >= _minFileSizeForMultipartMB;
  }

  void incrementParts() {
    final maxParts = getMaxAllowedParts();
    if (numberOfParts.value < maxParts) {
      numberOfParts.value++;
    } else {
      Utils.showToast(
        'Maximum $maxParts parts allowed (each part must be at least 5MB)',
      );
    }
  }

  void decrementParts() {
    if (numberOfParts.value > 1) {
      numberOfParts.value--;
    }
  }

  void _adjustNumberOfParts() {
    final fileSizeInMB = _getFileSizeInMB();
    if (fileSizeInMB < _minFileSizeForMultipartMB) {
      numberOfParts.value = 1;
    } else {
      final maxParts = getMaxAllowedParts();
      if (numberOfParts.value > maxParts) {
        numberOfParts.value = maxParts;
      }
    }
  }

  Future<void> _extractVideoDuration(String filePath) async {
    final metaData = await galleryController.getMediaMetadata(filePath);
    if (metaData != null) {
      final data = metaData.$1;
      if (data.startsWith('Duration: ')) {
        final durStr = data.replaceAll('Duration: ', '');
        final parts = durStr.split(':');
        if (parts.length == 3) {
          final paddedParts = [
            parts[0].length == 1 ? '0${parts[0]}' : parts[0],
            parts[1],
            parts[2],
          ];
          duration.value = paddedParts.join(':');
        } else {
          duration.value = durStr;
        }
      }
    }
  }

  Future<void> _generateVideoThumbnail(String filePath) async {
    try {
      final bytes = await VideoThumbnail.thumbnailData(
        video: filePath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 1280,
        quality: 75,
      );
      thumbnailBytes.value = bytes;
    } catch (e) {
      if (kDebugMode) {
        print('Error generating thumbnail: $e');
      }
    }
  }

  Future<void> _generateVideoThumbnailWeb(Uint8List videoBytes) async {
    try {
      // For web, we can use video_thumbnail with a temporary file approach
      // or use a web-compatible method. Since video_thumbnail may not work on web,
      // we'll create a video element approach or use a simpler method.
      // For now, we'll try to use video_thumbnail if it supports web, otherwise show placeholder
      if (kIsWeb) {
        // On web, video thumbnail generation is complex.
        // We can use html package to create a video element and capture a frame,
        // but for simplicity, we'll set a placeholder or try video_thumbnail
        try {
          // Try using video_thumbnail - it might work if the package supports web
          // For now, we'll leave thumbnail as null and show a placeholder
          thumbnailBytes.value = null;
        } catch (e) {
          if (kDebugMode) {
            print('Video thumbnail not available on web: $e');
          }
          thumbnailBytes.value = null;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error generating web video thumbnail: $e');
      }
      thumbnailBytes.value = null;
    }
  }

  void _initializeMediaInfo() async {
    try {
      if (kIsWeb && filePath.startsWith('web_media_')) {
        // Web: Get from Hive storage
        final id = filePath.replaceFirst('web_media_', '');
        final bytes = await _webStorage.getMediaBytes(id);
        if (bytes == null) return;

        sizeInBytes.value = bytes.length;
        fileSize.value = _formatBytes(sizeInBytes.value);
        _adjustNumberOfParts();

        // Get media type from stored item
        final allMedia = _webStorage.getAllMedia();
        final mediaItem = allMedia.firstWhereOrNull((item) => item.id == id);
        if (mediaItem != null) {
          mediaType.value = mediaItem.mediaType;
        } else {
          mediaType.value = galleryController.getMediaType(filePath);
        }

        if (mediaType.value == 'VIDEO') {
          // For web videos, try to generate thumbnail from bytes
          await _generateVideoThumbnailWeb(bytes);
          duration.value = '0';
        } else {
          duration.value = '0';
        }
      } else {
        // Mobile/Desktop: Use file system
        final file = File(filePath);
        if (!await file.exists()) return;

        sizeInBytes.value = await file.length();
        fileSize.value = _formatBytes(sizeInBytes.value);
        _adjustNumberOfParts();
        mediaType.value = galleryController.getMediaType(filePath);

        if (mediaType.value == 'VIDEO') {
          await _extractVideoDuration(filePath);
          await _generateVideoThumbnail(filePath);
        } else {
          duration.value = '0';
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing media info: $e');
      }
      Get.dialog(
        ErrorDialog(
          title: 'Media Error',
          subTitle: 'Something went wrong while initializing media',
        ),
      );
    }
  }

  String _formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    // Actually standard math log is better but keeping it simple
    // Let's use a simpler approach or copying if utils exist.
    // Basic impl:
    var i2 = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i2)).toStringAsFixed(decimals)} ${suffixes[i2]}';
  }

  // Actually, let's just use a simple divider for MB
  String getFileSizeString() {
    double sizeInMb = sizeInBytes.value / (1024 * 1024);
    return '${sizeInMb.toStringAsFixed(2)} MB';
  }

  // Convert duration string (HH:MM:SS) to seconds (integer)
  int _parseDurationToSeconds(String durationStr) {
    try {
      if (durationStr.isEmpty || durationStr == '0') {
        return 0;
      }

      // Parse HH:MM:SS format
      List<String> parts = durationStr.split(':');
      if (parts.length == 3) {
        int hours = int.parse(parts[0]);
        int minutes = int.parse(parts[1]);
        int seconds = int.parse(parts[2]);
        return (hours * 3600) + (minutes * 60) + seconds;
      } else if (parts.length == 2) {
        // MM:SS format
        int minutes = int.parse(parts[0]);
        int seconds = int.parse(parts[1]);
        return (minutes * 60) + seconds;
      } else {
        // Try parsing as integer (seconds)
        return int.parse(durationStr);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing duration: $e');
      }
      return 0;
    }
  }

  Map<String, dynamic> generatePayload() {
    // Get file extension for fileType
    String fileExtension = 'UNKNOWN';
    if (kIsWeb && filePath.startsWith('web_media_')) {
      // Web: Get extension from stored media item
      final id = filePath.replaceFirst('web_media_', '');
      final allMedia = _webStorage.getAllMedia();
      final mediaItem = allMedia.firstWhereOrNull((item) => item.id == id);
      if (mediaItem != null && mediaItem.fileName.contains('.')) {
        fileExtension = mediaItem.fileName.split('.').last.toUpperCase();
      }
    } else if (filePath.contains('.')) {
      fileExtension = filePath.split('.').last.toUpperCase();
    }

    return {
      "amountOfParts": numberOfParts.value,
      "fileType": fileExtension, // e.g., PNG, JPG, MP4
      "metadata": {
        "title": titleController.text,
        "type": mediaType.value, // IMAGE or VIDEO
        "resolution": resolution.value,
        "size": sizeInBytes.value,
        "metadata": metadataController.text,
        "tags": {
          for (var tag in tagControllers)
            if (tag['key']!.text.isNotEmpty)
              tag['key']!.text: tag['value']!.text,
        },
        "duration": mediaType.value == 'VIDEO'
            ? _parseDurationToSeconds(duration.value)
            : 0,
        "creator": creatorController.text,
        "includeInReport": includeInReport.value,
        "isLibrary": isLibrary.value,
      },
    };
  }

  // Validation helpers
  bool _validateRequiredFields() {
    if (titleController.text.isEmpty || creatorController.text.isEmpty) {
      Utils.showToast('Title and creator name are required');
      return false;
    }
    return true;
  }

  bool _validateNumberOfParts() {
    final fileSizeInMB = _getFileSizeInMB();
    final maxParts = getMaxAllowedParts();

    if (fileSizeInMB < _minFileSizeForMultipartMB && numberOfParts.value > 1) {
      Utils.showToast('Files below 10MB cannot be uploaded in parts');
      numberOfParts.value = 1;
      return false;
    }

    if (fileSizeInMB >= _minFileSizeForMultipartMB) {
      if (numberOfParts.value > maxParts) {
        Utils.showToast(
          'Maximum $maxParts parts allowed. Each part must be at least 5MB',
        );
        numberOfParts.value = maxParts;
        return false;
      }

      final partSizeInMB = fileSizeInMB / numberOfParts.value;
      if (partSizeInMB < _minPartSizeMB) {
        Utils.showToast(
          'Each part must be at least 5MB. Maximum $maxParts parts allowed',
        );
        numberOfParts.value = maxParts;
        return false;
      }
    }
    return true;
  }

  void _clearPreviousUploadData() {
    uploadParts.clear();
    uploadedParts.clear();
    uploadResponseHeaders.clear();
  }

  void _clearPreviousResponses() {
    initializeResponse.value = null;
    uploadResponse.value = null;
    finalizeResponse.value = null;
    uploadPayload.value = null;
    finalizePayload.value = null;
  }

  void _processInitializeResponse(Map<String, dynamic> response) {
    uploadId = response['uploadId'];
    _clearPreviousUploadData();

    if (response['uploadParts'] != null &&
        (response['uploadParts'] as List).isNotEmpty) {
      uploadParts = List<Map<String, dynamic>>.from(response['uploadParts']);
      if (uploadParts.isNotEmpty) {
        uploadPresignedUrl = uploadParts[0]['uploadPresignedUrl'];
      }
    }
  }

  // Step 1: Initialize Upload
  void onInitialize() async {
    if (!_validateRequiredFields() || !_validateNumberOfParts()) {
      return;
    }
    if (!await ConnectivityService().hasConnection()) {
      Get.dialog(
        ErrorDialog(
          title: 'Internet Error',
          subTitle: 'Make sure you have stable internet connection',
        ),
      );
      return;
    }

    isStepLoading.value = true;
    try {
      _clearPreviousResponses();

      final payload = generatePayload();
      initializePayload.value = payload;

      final token = storage.read<String>(_boTokenKey) ?? '';
      final response = await ApiService().post<Map<String, dynamic>>(
        path: Endpoints.initializeUpload,
        data: payload,
        token: token,
      );

      if (response != null) {
        _processInitializeResponse(response);
        initializeResponse.value = response;
        isInitializeComplete.value = true;
        currentStep.value = 1;
        Utils.showToast('Initialize completed successfully!');
      } else {
        Get.dialog(
          ErrorDialog(
            title: 'Initialize Failed',
            subTitle: 'Failed to initialize upload. Please try again.',
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in Initialize: $e');
      }
      Get.dialog(
        ErrorDialog(
          title: 'Initialize Error',
          subTitle: 'Failed to initialize upload: ${e.toString()}',
        ),
      );
    } finally {
      isStepLoading.value = false;
    }
  }

  // Upload helpers
  void _initializeUploadProgress(int totalParts) {
    totalUploadParts.value = totalParts;
    currentUploadPart.value = 0;
    uploadProgress.value = 0.0;
    uploadedParts.clear();
  }

  void _storeUploadPayload() {
    if (uploadParts.length > 1) {
      uploadPayload.value = {
        'type': 'multipart',
        'totalParts': uploadParts.length,
        'presignedUrls': uploadParts
            .map(
              (part) => {
                'partNumber': part['partNumber'],
                'url': part['uploadPresignedUrl'],
              },
            )
            .toList(),
      };
    } else {
      final url = uploadParts.isNotEmpty
          ? uploadParts[0]['uploadPresignedUrl']
          : uploadPresignedUrl;
      if (url != null) {
        uploadPayload.value = {'type': 'single', 'presignedUrl': url};
      }
    }
  }

  Map<String, String> _extractResponseHeaders(dio.Response response) {
    final headers = <String, String>{};
    response.headers.forEach((key, values) {
      headers[key] = values.join(', ');
    });
    return headers;
  }

  String? _extractEtag(dio.Response response) {
    final rawEtag =
        response.headers.value('ETag') ?? response.headers.value('etag');
    return rawEtag?.replaceAll('"', '');
  }

  void _storeUploadResponseHeader(
    int partNumber,
    int statusCode,
    Map<String, String> headers,
  ) {
    uploadResponseHeaders.add({
      'partNumber': partNumber,
      'statusCode': statusCode,
      'headers': headers,
    });
  }

  void _buildUploadResponse() {
    if (uploadResponseHeaders.isEmpty) return;

    if (uploadResponseHeaders.length == 1) {
      final headerData = uploadResponseHeaders[0];
      final headers = headerData['headers'] as Map<String, String>;
      final etag = headers['etag'] ?? headers['ETag'] ?? '';
      uploadResponse.value = {
        'partNumber': headerData['partNumber'],
        'etag': etag.replaceAll('"', ''),
        'statusCode': headerData['statusCode'],
      };
    } else {
      final parts = uploadResponseHeaders.map((headerData) {
        final headers = headerData['headers'] as Map<String, String>;
        final etag = headers['etag'] ?? headers['ETag'] ?? '';
        return {
          'partNumber': headerData['partNumber'],
          'etag': etag.replaceAll('"', ''),
          'statusCode': headerData['statusCode'],
        };
      }).toList();
      uploadResponse.value = {'parts': parts};
    }
  }

  Future<void> _uploadMultipartPart(
    File file,
    int index,
    int totalParts,
    int totalSize,
    int chunkSize,
  ) async {
    final part = uploadParts[index];
    final partNumber = part['partNumber'] as int;
    final presignedUrl = part['uploadPresignedUrl'] as String;

    currentUploadPart.value = partNumber;
    uploadProgress.value = 0.0;

    final startByte = index * chunkSize;
    final endByte = (index == totalParts - 1)
        ? totalSize
        : ((index + 1) * chunkSize);
    final partSize = endByte - startByte;

    final randomAccessFile = await file.open(mode: FileMode.read);
    try {
      await randomAccessFile.setPosition(startByte);
      final chunkBytes = await randomAccessFile.read(partSize);

      final dioInstance = Dio();
      final response = await dioInstance.put(
        presignedUrl,
        data: chunkBytes,
        options: Options(headers: {'Content-Type': ''}),
        onSendProgress: (sent, total) {
          final partProgress = (sent / total) * 100;
          uploadProgress.value = partProgress.clamp(0.0, 100.0);
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        uploadProgress.value = 100.0;

        final headers = _extractResponseHeaders(response);
        _storeUploadResponseHeader(partNumber, response.statusCode!, headers);

        final etagValue = _extractEtag(response);
        if (etagValue != null) {
          uploadedParts.add({
            'etag': etagValue,
            'partNumber': partNumber.toString(),
          });
          if (index < totalParts - 1) {
            uploadProgress.value = 0.0;
          }
        } else {
          Get.dialog(
            ErrorDialog(
              title: 'Upload Error',
              subTitle: 'No ETag received for part $partNumber',
            ),
          );
          throw Exception('No ETag for part $partNumber');
        }
      } else {
        Get.dialog(
          ErrorDialog(
            title: 'Upload Error',
            subTitle:
                'Failed to upload part $partNumber. Status code: ${response.statusCode}',
          ),
        );
        throw Exception('Upload failed for part $partNumber');
      }
    } finally {
      await randomAccessFile.close();
    }
  }

  Future<void> _uploadSinglePart(File file, int totalSize) async {
    currentUploadPart.value = 1;

    final dioInstance = Dio();
    final response = await dioInstance.put(
      uploadPresignedUrl!,
      data: file.openRead(),
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': totalSize,
        },
      ),
      onSendProgress: (sent, total) {
        final progress = (sent / total) * 100;
        uploadProgress.value = progress.clamp(0.0, 100.0);
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final headers = _extractResponseHeaders(response);
      _storeUploadResponseHeader(1, response.statusCode!, headers);

      final etagValue = _extractEtag(response);
      if (etagValue != null) {
        etag = etagValue;
        uploadedParts.add({'etag': etagValue, 'partNumber': '1'});
      }
    } else {
      Get.dialog(
        ErrorDialog(
          title: 'Upload Error',
          subTitle:
              'Failed to upload file. Status code: ${response.statusCode}',
        ),
      );
      throw Exception('Single part upload failed');
    }
  }

  Future<void> _uploadSinglePartWeb(Uint8List bytes, int totalSize) async {
    currentUploadPart.value = 1;

    final dioInstance = Dio();
    final response = await dioInstance.put(
      uploadPresignedUrl!,
      data: bytes,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': totalSize,
        },
      ),
      onSendProgress: (sent, total) {
        final progress = (sent / total) * 100;
        uploadProgress.value = progress.clamp(0.0, 100.0);
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final headers = _extractResponseHeaders(response);
      _storeUploadResponseHeader(1, response.statusCode!, headers);

      final etagValue = _extractEtag(response);
      if (etagValue != null) {
        etag = etagValue;
        uploadedParts.add({'etag': etagValue, 'partNumber': '1'});
      }
    } else {
      Get.dialog(
        ErrorDialog(
          title: 'Upload Error',
          subTitle:
              'Failed to upload file. Status code: ${response.statusCode}',
        ),
      );
      throw Exception('Single part upload failed');
    }
  }

  Future<void> _uploadMultipartPartWeb(
    Uint8List bytes,
    int index,
    int totalParts,
    int totalSize,
    int chunkSize,
  ) async {
    final part = uploadParts[index];
    final partNumber = part['partNumber'] as int;
    final presignedUrl = part['uploadPresignedUrl'] as String;

    currentUploadPart.value = partNumber;
    uploadProgress.value = 0.0;

    final startByte = index * chunkSize;
    final endByte = (index == totalParts - 1)
        ? totalSize
        : ((index + 1) * chunkSize);
    final partSize = endByte - startByte;
    final chunkBytes = bytes.sublist(startByte, endByte);

    final dioInstance = Dio();
    final response = await dioInstance.put(
      presignedUrl,
      data: chunkBytes,
      options: Options(headers: {'Content-Type': ''}),
      onSendProgress: (sent, total) {
        final partProgress = (sent / total) * 100;
        uploadProgress.value = partProgress.clamp(0.0, 100.0);
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      uploadProgress.value = 100.0;

      final headers = _extractResponseHeaders(response);
      _storeUploadResponseHeader(partNumber, response.statusCode!, headers);

      final etagValue = _extractEtag(response);
      if (etagValue != null) {
        uploadedParts.add({
          'etag': etagValue,
          'partNumber': partNumber.toString(),
        });
        if (index < totalParts - 1) {
          uploadProgress.value = 0.0;
        }
      } else {
        Get.dialog(
          ErrorDialog(
            title: 'Upload Error',
            subTitle: 'No ETag received for part $partNumber',
          ),
        );
        throw Exception('No ETag for part $partNumber');
      }
    } else {
      Get.dialog(
        ErrorDialog(
          title: 'Upload Error',
          subTitle:
              'Failed to upload part $partNumber. Status code: ${response.statusCode}',
        ),
      );
      throw Exception('Upload failed for part $partNumber');
    }
  }

  // Step 2: Upload File
  void onUploadFile() async {
    if (!isInitializeComplete.value) {
      Utils.showToast('Please complete Initialize step first');
      return;
    }

    if (uploadParts.isEmpty &&
        (uploadPresignedUrl == null || uploadPresignedUrl!.isEmpty)) {
      Utils.showToast('No presigned URL available');
      return;
    }
    if (!await ConnectivityService().hasConnection()) {
      Get.dialog(
        ErrorDialog(
          title: 'Internet Error',
          subTitle: 'Make sure you have stable internet connection',
        ),
      );
      return;
    }

    isStepLoading.value = true;
    try {
      int totalSize;
      Uint8List? webBytes;

      if (kIsWeb && filePath.startsWith('web_media_')) {
        // Web: Get bytes from storage
        final id = filePath.replaceFirst('web_media_', '');
        webBytes = await _webStorage.getMediaBytes(id);
        if (webBytes == null) {
          throw Exception('Failed to load file from storage');
        }
        totalSize = webBytes.length;
      } else {
        // Mobile/Desktop: Use file system
        final file = File(filePath);
        totalSize = await file.length();
      }

      final isMultipart = uploadParts.length > 1;

      _initializeUploadProgress(isMultipart ? uploadParts.length : 1);
      _storeUploadPayload();

      if (isMultipart) {
        final chunkSize = (totalSize / uploadParts.length).ceil();
        for (var i = 0; i < uploadParts.length; i++) {
          if (kIsWeb && webBytes != null) {
            await _uploadMultipartPartWeb(
              webBytes,
              i,
              uploadParts.length,
              totalSize,
              chunkSize,
            );
          } else {
            await _uploadMultipartPart(
              File(filePath),
              i,
              uploadParts.length,
              totalSize,
              chunkSize,
            );
          }
        }
        if (uploadedParts.isNotEmpty) {
          etag = uploadedParts[0]['etag'];
        }
      } else {
        if (kIsWeb && webBytes != null) {
          await _uploadSinglePartWeb(webBytes, totalSize);
        } else {
          await _uploadSinglePart(File(filePath), totalSize);
        }
      }

      _buildUploadResponse();

      isUploadComplete.value = true;
      currentStep.value = 2;
      uploadProgress.value = 100.0;
      Utils.showToast('File uploaded successfully!');
    } catch (e) {
      if (kDebugMode) {
        print('Error in Upload File: $e');
      }
      Get.dialog(
        ErrorDialog(
          title: 'Upload Error',
          subTitle: 'Failed to upload file: ${e.toString()}',
        ),
      );
      uploadedParts.clear();
      uploadProgress.value = 0.0;
      currentUploadPart.value = 0;
    } finally {
      isStepLoading.value = false;
    }
  }

  // Finalize helpers
  bool _validateFinalizePrerequisites() {
    if (!isUploadComplete.value) {
      Utils.showToast('Please complete Upload step first');
      return false;
    }

    if (uploadId == null || uploadedParts.isEmpty) {
      Utils.showToast('Missing uploadId or uploaded parts');
      return false;
    }

    if (uploadParts.length > 1 && uploadedParts.length != uploadParts.length) {
      Utils.showToast(
        'Not all parts have been uploaded. Expected ${uploadParts.length} parts, got ${uploadedParts.length}',
      );
      return false;
    }
    return true;
  }

  Map<String, dynamic> _buildFinalizePayload() {
    final sortedParts = [
      {"partNumber": '1', "etag": "dcascascascascasc"},
    ];
    // final sortedParts = List<Map<String, String>>.from(uploadedParts);
    sortedParts.sort((a, b) {
      final partNumA = int.parse(a['partNumber']!);
      final partNumB = int.parse(b['partNumber']!);
      return partNumA.compareTo(partNumB);
    });

    final parts = sortedParts
        .map(
          (part) => {
            "etag": part['etag'],
            "partNumber": int.parse(part['partNumber']!),
          },
        )
        .toList();

    return {"parts": parts, "uploadId": uploadId};
  }

  void _processFinalizeResponse(dio.Response response) {
    if (response.data is Map) {
      finalizeResponse.value = Map<String, dynamic>.from(response.data);
    } else {
      finalizeResponse.value = {
        'status': 'success',
        'statusCode': response.statusCode,
        'message': 'Upload completed successfully',
      };
    }
    isFinalizeComplete.value = true;
    Utils.showToast('Finalize completed successfully!');
  }

  // Step 3: Finalize Upload
  void onFinalize() async {
    print('////////////////////////////////');
    // if (!_validateFinalizePrerequisites()) return;
    if (!await ConnectivityService().hasConnection()) {
      Get.dialog(
        ErrorDialog(
          title: 'Internet Error',
          subTitle: 'Make sure you have stable internet connection',
        ),
      );
      return;
    }

    isStepLoading.value = true;
    try {
      final token = storage.read<String>(_boTokenKey) ?? '';
      final payload = _buildFinalizePayload();
      finalizePayload.value = payload;

      final dioInstance = Dio(BaseOptions(baseUrl: Endpoints.baseUrl));
      final response = await dioInstance.post(
        Endpoints.finalizeUpload,
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _processFinalizeResponse(response);
      } else {
        Get.dialog(
          ErrorDialog(
            title: 'Finalize Failed',
            subTitle:
                'Failed to finalize upload. Status code: ${response.statusCode}',
          ),
        );
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('DioException in Finalize: ${e.message}');
      }
      Get.dialog(
        ErrorDialog(
          title: 'Finalize Error',
          subTitle:
              'Failed to finalize upload: ${e.response?.data?.toString() ?? e.message ?? 'Unknown error'}',
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error in Finalize: $e');
      }
      Get.dialog(
        ErrorDialog(
          title: 'Finalize Error',
          subTitle: 'Failed to finalize upload: ${e.toString()}',
        ),
      );
    } finally {
      isStepLoading.value = false;
    }
  }
}
