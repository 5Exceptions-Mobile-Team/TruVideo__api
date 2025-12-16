import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:media_upload_sample_app/core/resourses/endpoints.dart';
import 'package:media_upload_sample_app/core/services/api_service.dart';
import 'package:media_upload_sample_app/core/utils/utils.dart';
import 'package:media_upload_sample_app/features/common/widgets/error_widget.dart';
import 'package:media_upload_sample_app/features/gallery/controller/gallery_controller.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:typed_data';

class MediaUploadController extends GetxController {
  GetStorage storage = GetStorage();
  final String filePath;

  MediaUploadController(this.filePath);

  late TextEditingController titleController;
  late TextEditingController creatorController;
  late TextEditingController metadataController;

  RxList<Map<String, TextEditingController>> tagControllers =
      <Map<String, TextEditingController>>[].obs;

  late GalleryController galleryController;

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

    // Attempt to find existing GalleryController or put a new one if needed (though usually it should exist)
    if (Get.isRegistered<GalleryController>()) {
      galleryController = Get.find<GalleryController>();
    } else {
      galleryController = Get.put(GalleryController());
    }
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

  // Get maximum allowed parts based on file size (each part must be at least 5MB)
  int getMaxAllowedParts() {
    if (sizeInBytes.value == 0) return 1;

    final fileSizeInMB = sizeInBytes.value / (1024 * 1024);

    // Files below 10MB cannot be uploaded in parts
    if (fileSizeInMB < 10) {
      return 1;
    }

    // Each part must be at least 5MB, so max parts = fileSizeInMB / 5 (rounded down)
    return (fileSizeInMB / 5).floor();
  }

  // Check if multipart upload is allowed for current file size
  bool isMultipartAllowed() {
    if (sizeInBytes.value == 0) return false;
    final fileSizeInMB = sizeInBytes.value / (1024 * 1024);
    return fileSizeInMB >= 10;
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

  void _initializeMediaInfo() async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        sizeInBytes.value = await file.length();
        fileSize.value = _formatBytes(sizeInBytes.value);

        // Auto-adjust number of parts based on file size
        final fileSizeInMB = sizeInBytes.value / (1024 * 1024);
        if (fileSizeInMB < 10) {
          // Files below 10MB must use 1 part
          numberOfParts.value = 1;
        } else {
          // For files >= 10MB, ensure parts don't exceed max allowed
          final maxParts = getMaxAllowedParts();
          if (numberOfParts.value > maxParts) {
            numberOfParts.value = maxParts;
          }
        }

        mediaType.value = galleryController.getMediaType(filePath);

        // Metadata extraction
        // Re-using logic similar to GalleryController or just generic extraction
        // Since GalleryController.getMediaMetadata returns formatted string, we might need to parse or re-implement for raw values
        // For now, let's re-implement basic extraction since we need specific values (duration as int)

        if (mediaType.value == 'VIDEO') {
          // We need duration. GalleryController uses MediaInfo.
          // Since we can't easily access the raw logic inside GalleryController's helper without parsing,
          // we'll use a cached value if available or defaults for now.
          // However, let's see if we can use the formatted metadata from GalleryController to at least display something,
          // but for the payload we need int.

          // We will rely on GalleryController's dependencies if we can import them,
          // but to save time/errors, let's assume 0 for now or try to parse if needed.
          // User instructions: "get all the other details like size, duration if video (0 for image)"
          // "There are already some func available in gallery controller... use those functions."

          final metaData = await galleryController.getMediaMetadata(filePath);
          if (metaData != null) {
            // metaData.$1 is e.g., "Duration: 12345" or "Resolution: 100x100"
            String data = metaData.$1;
            if (data.startsWith('Duration: ')) {
              String durStr = data.replaceAll('Duration: ', '');
              // Ensure format HH:MM:SS (pad hours)
              List<String> parts = durStr.split(':');
              if (parts.length == 3) {
                if (parts[0].length == 1) {
                  parts[0] = '0${parts[0]}';
                }
                duration.value = parts.join(':');
              } else {
                duration.value = durStr;
              }
            }
          }

          // Generate Thumbnail for video
          final bytes = await VideoThumbnail.thumbnailData(
            video: filePath,
            imageFormat: ImageFormat.JPEG,
            maxWidth: 1280, // High quality for preview
            quality: 75,
          );
          thumbnailBytes.value = bytes;
        } else {
          duration.value = '0';
        }
      }
    } catch (e) {
      print('Error initializing media info: $e');
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
      print('Error parsing duration: $e');
      return 0;
    }
  }

  Map<String, dynamic> generatePayload() {
    // Get file extension for fileType
    String fileExtension = filePath.split('.').last.toUpperCase();

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

  // Step 1: Initialize Upload
  void onInitialize() async {
    if (titleController.text.isEmpty || creatorController.text.isEmpty) {
      Utils.showToast('Title and creator name are required');
      return;
    }

    // Validate number of parts based on file size
    final fileSizeInMB = sizeInBytes.value / (1024 * 1024);

    // Files below 10MB cannot be uploaded in parts
    if (fileSizeInMB < 10 && numberOfParts.value > 1) {
      Utils.showToast('Files below 10MB cannot be uploaded in parts');
      numberOfParts.value = 1;
      return;
    }

    // For files >= 10MB, validate that each part is at least 5MB
    if (fileSizeInMB >= 10) {
      final maxParts = getMaxAllowedParts();
      if (numberOfParts.value > maxParts) {
        Utils.showToast(
          'Maximum $maxParts parts allowed. Each part must be at least 5MB',
        );
        numberOfParts.value = maxParts;
        return;
      }

      final partSizeInMB = fileSizeInMB / numberOfParts.value;
      if (partSizeInMB < 5) {
        Utils.showToast(
          'Each part must be at least 5MB. Maximum $maxParts parts allowed',
        );
        numberOfParts.value = maxParts;
        return;
      }
    }

    isStepLoading.value = true;
    try {
      // Clear previous responses and payloads when starting new initialize
      initializeResponse.value = null;
      uploadResponse.value = null;
      finalizeResponse.value = null;
      uploadPayload.value = null;
      finalizePayload.value = null;

      Map<String, dynamic> payload = generatePayload();
      print("Step 1 - Initialize Upload with payload:");
      print(payload);

      // Store payload for display
      initializePayload.value = payload;

      final token = storage.read<String>('bo_token') ?? '';
      // Call Initialize API
      final response = await ApiService().post<Map<String, dynamic>>(
        path: Endpoints.initializeUpload,
        data: payload,
        token: token,
      );

      if (response != null) {
        // Store response data
        uploadId = response['uploadId'];

        // Clear previous upload parts and responses
        uploadParts.clear();
        uploadedParts.clear();
        uploadResponseHeaders.clear();
        // Don't clear payloads and responses here - they should remain visible

        if (response['uploadParts'] != null &&
            (response['uploadParts'] as List).isNotEmpty) {
          // Store all upload parts for multipart upload
          uploadParts = List<Map<String, dynamic>>.from(
            response['uploadParts'],
          );

          // For backward compatibility, store first part URL
          if (uploadParts.isNotEmpty) {
            uploadPresignedUrl = uploadParts[0]['uploadPresignedUrl'];
          }
        }

        // Store response for display
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
      print('Error in Initialize: $e');
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

  // Step 2: Upload File
  void onUploadFile() async {
    if (!isInitializeComplete.value) {
      Get.snackbar('Error', 'Please complete Initialize step first');
      return;
    }

    if (uploadParts.isEmpty &&
        (uploadPresignedUrl == null || uploadPresignedUrl!.isEmpty)) {
      Get.snackbar('Error', 'No presigned URL available');
      return;
    }

    isStepLoading.value = true;
    try {
      // Get file info without loading into memory
      final file = File(filePath);
      final totalSize = await file.length();

      // Clear previous uploaded parts
      uploadedParts.clear();

      // Initialize progress tracking
      totalUploadParts.value = uploadParts.length > 1 ? uploadParts.length : 1;
      currentUploadPart.value = 0;
      uploadProgress.value = 0.0;

      // Store upload payload (presigned URLs info)
      if (uploadParts.isNotEmpty && uploadParts.length > 1) {
        // Multipart upload
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
      } else if (uploadParts.isNotEmpty) {
        // Single part from uploadParts array
        uploadPayload.value = {
          'type': 'single',
          'presignedUrl': uploadParts[0]['uploadPresignedUrl'],
        };
      } else if (uploadPresignedUrl != null) {
        // Single part from legacy uploadPresignedUrl
        uploadPayload.value = {
          'type': 'single',
          'presignedUrl': uploadPresignedUrl,
        };
      }

      // Check if multipart upload
      if (uploadParts.length > 1) {
        // Calculate chunk size
        final chunkSize = (totalSize / uploadParts.length).ceil();

        // Upload each part using streaming to avoid loading entire file into memory
        for (var i = 0; i < uploadParts.length; i++) {
          final part = uploadParts[i];
          final partNumber = part['partNumber'] as int;
          final presignedUrl = part['uploadPresignedUrl'] as String;

          // Update current part and reset progress for new part
          currentUploadPart.value = partNumber;
          uploadProgress.value = 0.0;

          // Calculate start and end byte positions
          final startByte = i * chunkSize;
          final endByte = (i == uploadParts.length - 1)
              ? totalSize
              : ((i + 1) * chunkSize);
          final partSize = endByte - startByte;

          // Read only the specific chunk from file using RandomAccessFile
          final randomAccessFile = await file.open(mode: FileMode.read);
          try {
            await randomAccessFile.setPosition(startByte);
            final chunkBytes = await randomAccessFile.read(partSize);

            // Create Dio instance for direct PUT request to presigned URL
            final dio = Dio();
            final response = await dio.put(
              presignedUrl,
              data: chunkBytes,
              options: Options(headers: {'Content-Type': ''}),
              onSendProgress: (sent, total) {
                // Calculate progress for current part only (0-100%)
                final partProgress = (sent / total) * 100;
                uploadProgress.value = partProgress.clamp(0.0, 100.0);
              },
            );

            if (response.statusCode == 200 || response.statusCode == 201) {
              // Set progress to 100% when part completes
              uploadProgress.value = 100.0;

              // Store response headers for display
              final headers = <String, String>{};
              response.headers.forEach((key, values) {
                headers[key] = values.join(', ');
              });
              uploadResponseHeaders.add({
                'partNumber': partNumber,
                'statusCode': response.statusCode,
                'headers': headers,
              });

              // Extract ETag from response headers
              String? rawEtag =
                  response.headers.value('ETag') ??
                  response.headers.value('etag');
              if (rawEtag != null) {
                // Remove surrounding quotes if present
                final cleanEtag = rawEtag.replaceAll('"', '');
                uploadedParts.add({
                  'etag': cleanEtag,
                  'partNumber': partNumber.toString(),
                });

                // Reset progress for next part (if not the last part)
                if (i < uploadParts.length - 1) {
                  uploadProgress.value = 0.0;
                }
              } else {
                Get.dialog(
                  ErrorDialog(
                    title: 'Upload Error',
                    subTitle: 'No ETag received for part $partNumber',
                  ),
                );
                return;
              }
            } else {
              Get.dialog(
                ErrorDialog(
                  title: 'Upload Error',
                  subTitle:
                      'Failed to upload part $partNumber. Status code: ${response.statusCode}',
                ),
              );
              return;
            }
          } finally {
            // Always close the file handle
            await randomAccessFile.close();
          }
        }

        // For backward compatibility, store first part's etag
        if (uploadedParts.isNotEmpty) {
          etag = uploadedParts[0]['etag'];
        }
      } else {
        // Single part upload (backward compatibility)
        // Use streaming for large files to avoid memory issues

        currentUploadPart.value = 1;

        // For large files, using stream to avoid loading entire file into memory
        final dio = Dio();
        final response = await dio.put(
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
          // Store response headers for display
          final headers = <String, String>{};
          response.headers.forEach((key, values) {
            headers[key] = values.join(', ');
          });
          uploadResponseHeaders.add({
            'partNumber': 1,
            'statusCode': response.statusCode,
            'headers': headers,
          });

          // Extract ETag from response headers
          String? rawEtag =
              response.headers.value('ETag') ?? response.headers.value('etag');
          if (rawEtag != null) {
            // Remove surrounding quotes if present
            etag = rawEtag.replaceAll('"', '');
            uploadedParts.add({'etag': etag!, 'partNumber': '1'});
          }
          print('Upload Success - ETag: $etag');
        } else {
          Get.dialog(
            ErrorDialog(
              title: 'Upload Error',
              subTitle:
                  'Failed to upload file. Status code: ${response.statusCode}',
            ),
          );
          return;
        }
      }

      // Store upload response headers for display (only partNumber, etag, statusCode)
      if (uploadResponseHeaders.isNotEmpty) {
        // Build response with only partNumber, etag, and statusCode
        if (uploadResponseHeaders.length == 1) {
          // Single part
          final headers =
              uploadResponseHeaders[0]['headers'] as Map<String, String>;
          final etag = headers['etag'] ?? headers['ETag'] ?? '';
          uploadResponse.value = {
            'partNumber': uploadResponseHeaders[0]['partNumber'],
            'etag': etag.replaceAll('"', ''),
            'statusCode': uploadResponseHeaders[0]['statusCode'],
          };
        } else {
          // Multiple parts - show array
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

      isUploadComplete.value = true;
      currentStep.value = 2;
      uploadProgress.value = 100.0; // Ensure progress is 100% on completion
      Utils.showToast('File uploaded successfully!');
    } catch (e) {
      print('Error in Upload File: $e');
      Get.dialog(
        ErrorDialog(
          title: 'Upload Error',
          subTitle: 'Failed to upload file: ${e.toString()}',
        ),
      );
      // Reset upload state on error
      uploadedParts.clear();
      uploadProgress.value = 0.0;
      currentUploadPart.value = 0;
    } finally {
      isStepLoading.value = false;
    }
  }

  // Step 3: Finalize Upload
  void onFinalize() async {
    if (!isUploadComplete.value) {
      Get.snackbar('Error', 'Please complete Upload step first');
      return;
    }

    if (uploadId == null || uploadedParts.isEmpty) {
      Get.snackbar('Error', 'Missing uploadId or uploaded parts');
      return;
    }

    // Validate that all parts are uploaded (for multipart uploads)
    if (uploadParts.length > 1 && uploadedParts.length != uploadParts.length) {
      Get.snackbar(
        'Error',
        'Not all parts have been uploaded. Expected ${uploadParts.length} parts, got ${uploadedParts.length}',
      );
      return;
    }

    isStepLoading.value = true;
    try {
      final token = storage.read<String>('bo_token') ?? '';

      // Prepare finalize payload with all parts
      // Sort parts by partNumber to ensure correct order
      final sortedParts = List<Map<String, String>>.from(uploadedParts);
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

      final payload = {"parts": parts, "uploadId": uploadId};

      // Store payload for display
      finalizePayload.value = payload;

      // Call Finalize API using Dio directly to get better error information
      final dio = Dio(BaseOptions(baseUrl: Endpoints.baseUrl));
      try {
        final response = await dio.post(
          Endpoints.finalizeUpload,
          data: payload,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Store finalize response for display
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
        print('DioException in Finalize: ${e.message}');
        Get.dialog(
          ErrorDialog(
            title: 'Finalize Error',
            subTitle:
                'Failed to finalize upload: ${e.response?.data?.toString() ?? e.message ?? 'Unknown error'}',
          ),
        );
      } catch (e) {
        print('Error in Finalize: $e');
        Get.dialog(
          ErrorDialog(
            title: 'Finalize Error',
            subTitle: 'Failed to finalize upload: ${e.toString()}',
          ),
        );
      }
    } catch (e) {
      print('Error in Finalize: $e');
      Get.snackbar('Error', 'Failed to finalize: $e');
    } finally {
      isStepLoading.value = false;
    }
  }
}
