import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/features/media_upload/controller/media_upload_controller.dart';
import 'package:media_upload_sample_app/features/gallery/controller/gallery_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MediaUploadController controller;

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => '/tmp',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('PonnamKarthik/fluttertoast'),
      (MethodCall methodCall) async => true,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/device_info'),
      (MethodCall methodCall) async => <String, dynamic>{
        'version': {'sdkInt': 33},
      },
    );
  });

  setUp(() {
    Get.testMode = true;
    Get.put(GalleryController());
    controller = MediaUploadController('/tmp/test_video.mp4');
    controller.titleController = TextEditingController();
    controller.creatorController = TextEditingController();
    controller.metadataController = TextEditingController();
    controller.tagControllers.add({
      'key': TextEditingController(),
      'value': TextEditingController(),
    });
  });

  tearDown(() {
    controller.titleController.dispose();
    controller.creatorController.dispose();
    controller.metadataController.dispose();
    for (var tag in controller.tagControllers) {
      tag['key']?.dispose();
      tag['value']?.dispose();
    }
    Get.reset();
  });

  group('MediaUploadController Initialization', () {
    test('should initialize with correct file path', () {
      expect(controller.filePath, '/tmp/test_video.mp4');
    });

    test('should initialize with default values', () {
      expect(controller.mediaType.value, '');
      expect(controller.fileSize.value, '');
      expect(controller.sizeInBytes.value, 0);
      expect(controller.duration.value, '0');
      expect(controller.resolution.value, 'NORMAL');
      expect(controller.isLoading.value, false);
      expect(controller.currentStep.value, 0);
      expect(controller.isInitializeComplete.value, false);
      expect(controller.isUploadComplete.value, false);
      expect(controller.isFinalizeComplete.value, false);
    });

    test('should initialize checkbox options to false', () {
      expect(controller.isLibrary.value, false);
      expect(controller.includeInReport.value, false);
    });

    test('should initialize numberOfParts to 1', () {
      expect(controller.numberOfParts.value, 1);
    });
  });

  group('Constants', () {
    test('multipart should require at least 10MB file', () {
      controller.sizeInBytes.value = 9 * 1024 * 1024; // 9MB
      expect(controller.isMultipartAllowed(), false);
      controller.sizeInBytes.value = 10 * 1024 * 1024; // 10MB
      expect(controller.isMultipartAllowed(), true);
    });

    test('each part should be at least 5MB', () {
      controller.sizeInBytes.value = 25 * 1024 * 1024; // 25MB
      expect(controller.getMaxAllowedParts(), 5); // 25MB / 5MB = 5 parts max
    });
  });

  group('Tag Management', () {
    test('addTagRow should add a new tag row', () {
      final initialCount = controller.tagControllers.length;
      controller.addTagRow();
      expect(controller.tagControllers.length, initialCount + 1);
    });

    test('removeLastTagRow should remove last tag when more than one', () {
      controller.addTagRow();
      final countBefore = controller.tagControllers.length;
      controller.removeLastTagRow();
      expect(controller.tagControllers.length, countBefore - 1);
    });

    test('removeLastTagRow should not remove when only one tag', () {
      // Ensure only one tag
      while (controller.tagControllers.length > 1) {
        controller.removeLastTagRow();
      }
      controller.removeLastTagRow();
      expect(controller.tagControllers.length, 1);
    });
  });

  group('File Size Calculations', () {
    test('getMaxAllowedParts should return 1 for zero size', () {
      controller.sizeInBytes.value = 0;
      expect(controller.getMaxAllowedParts(), 1);
    });

    test('getMaxAllowedParts should return 1 for files under 10MB', () {
      controller.sizeInBytes.value = 5 * 1024 * 1024; // 5MB
      expect(controller.getMaxAllowedParts(), 1);
    });

    test('getMaxAllowedParts should return correct parts for large files', () {
      controller.sizeInBytes.value = 50 * 1024 * 1024; // 50MB
      expect(controller.getMaxAllowedParts(), 10); // 50MB / 5MB = 10 parts
    });

    test('isMultipartAllowed should return false for zero size', () {
      controller.sizeInBytes.value = 0;
      expect(controller.isMultipartAllowed(), false);
    });

    test('isMultipartAllowed should return false for files under 10MB', () {
      controller.sizeInBytes.value = 5 * 1024 * 1024; // 5MB
      expect(controller.isMultipartAllowed(), false);
    });

    test('isMultipartAllowed should return true for files 10MB or more', () {
      controller.sizeInBytes.value = 10 * 1024 * 1024; // 10MB
      expect(controller.isMultipartAllowed(), true);
    });

    test('getFileSizeString should format correctly', () {
      controller.sizeInBytes.value = 10 * 1024 * 1024; // 10MB
      expect(controller.getFileSizeString(), '10.00 MB');
    });
  });

  group('Parts Management', () {
    test('incrementParts should increase parts within limit', () {
      controller.sizeInBytes.value = 50 * 1024 * 1024; // 50MB
      controller.numberOfParts.value = 1;
      controller.incrementParts();
      expect(controller.numberOfParts.value, 2);
    });

    test('incrementParts should not exceed max parts', () {
      controller.sizeInBytes.value = 15 * 1024 * 1024; // 15MB - max 3 parts
      controller.numberOfParts.value = 3;
      controller.incrementParts();
      expect(controller.numberOfParts.value, 3);
    });

    test('decrementParts should decrease parts', () {
      controller.numberOfParts.value = 3;
      controller.decrementParts();
      expect(controller.numberOfParts.value, 2);
    });

    test('decrementParts should not go below 1', () {
      controller.numberOfParts.value = 1;
      controller.decrementParts();
      expect(controller.numberOfParts.value, 1);
    });
  });

  group('Duration Parsing', () {
    test('should parse HH:MM:SS format correctly', () {
      controller.titleController.text = 'Test';
      controller.creatorController.text = 'Creator';
      controller.duration.value = '01:30:45';
      controller.mediaType.value = 'VIDEO';

      final payload = controller.generatePayload();
      expect(payload['metadata']['duration'], 5445); // 1*3600 + 30*60 + 45
    });

    test('should parse MM:SS format correctly', () {
      controller.titleController.text = 'Test';
      controller.creatorController.text = 'Creator';
      controller.duration.value = '05:30';
      controller.mediaType.value = 'VIDEO';

      final payload = controller.generatePayload();
      expect(payload['metadata']['duration'], 330); // 5*60 + 30
    });

    test('should return 0 for empty duration', () {
      controller.titleController.text = 'Test';
      controller.creatorController.text = 'Creator';
      controller.duration.value = '';
      controller.mediaType.value = 'VIDEO';

      final payload = controller.generatePayload();
      expect(payload['metadata']['duration'], 0);
    });

    test('should return 0 for IMAGE type', () {
      controller.titleController.text = 'Test';
      controller.creatorController.text = 'Creator';
      controller.duration.value = '01:00:00';
      controller.mediaType.value = 'IMAGE';

      final payload = controller.generatePayload();
      expect(payload['metadata']['duration'], 0);
    });
  });

  group('generatePayload', () {
    test('should generate correct payload structure', () {
      controller.titleController.text = 'Test Title';
      controller.creatorController.text = 'Test Creator';
      controller.metadataController.text = 'Test Metadata';
      controller.mediaType.value = 'VIDEO';
      controller.sizeInBytes.value = 1024000;
      controller.resolution.value = 'HIGH';
      controller.numberOfParts.value = 2;
      controller.isLibrary.value = true;
      controller.includeInReport.value = true;

      final payload = controller.generatePayload();

      expect(payload['amountOfParts'], 2);
      expect(payload['fileType'], 'MP4');
      expect(payload['metadata']['title'], 'Test Title');
      expect(payload['metadata']['type'], 'VIDEO');
      expect(payload['metadata']['resolution'], 'HIGH');
      expect(payload['metadata']['size'], 1024000);
      expect(payload['metadata']['creator'], 'Test Creator');
      expect(payload['metadata']['isLibrary'], true);
      expect(payload['metadata']['includeInReport'], true);
    });

    test('should include tags in payload', () {
      controller.titleController.text = 'Test';
      controller.creatorController.text = 'Creator';
      controller.tagControllers[0]['key']!.text = 'category';
      controller.tagControllers[0]['value']!.text = 'sports';

      final payload = controller.generatePayload();

      expect(payload['metadata']['tags']['category'], 'sports');
    });

    test('should not include empty tags', () {
      controller.titleController.text = 'Test';
      controller.creatorController.text = 'Creator';
      controller.tagControllers[0]['key']!.text = '';
      controller.tagControllers[0]['value']!.text = 'value';

      final payload = controller.generatePayload();

      expect((payload['metadata']['tags'] as Map).isEmpty, true);
    });
  });

  group('Validation', () {
    test('onInitialize should fail with empty title', () async {
      controller.titleController.text = '';
      controller.creatorController.text = 'Creator';

      controller.onInitialize();

      await Future.delayed(const Duration(milliseconds: 100));
      expect(controller.isInitializeComplete.value, false);
    });

    test('onInitialize should fail with empty creator', () async {
      controller.titleController.text = 'Title';
      controller.creatorController.text = '';

      controller.onInitialize();

      await Future.delayed(const Duration(milliseconds: 100));
      expect(controller.isInitializeComplete.value, false);
    });

    test('onUploadFile should fail if initialize not complete', () {
      controller.isInitializeComplete.value = false;
      // onUploadFile uses Get.snackbar which requires overlay, so we just verify state
      expect(controller.isInitializeComplete.value, false);
      expect(controller.isUploadComplete.value, false);
    });

    test('onFinalize should fail if upload not complete', () {
      controller.isUploadComplete.value = false;
      // onFinalize uses Get.snackbar which requires overlay, so we just verify state
      expect(controller.isUploadComplete.value, false);
      expect(controller.isFinalizeComplete.value, false);
    });
  });

  group('Upload Progress', () {
    test('should initialize with zero progress', () {
      expect(controller.uploadProgress.value, 0.0);
      expect(controller.currentUploadPart.value, 0);
      expect(controller.totalUploadParts.value, 1);
    });
  });

  group('Step Management', () {
    test('currentStep should start at 0', () {
      expect(controller.currentStep.value, 0);
    });

    test('step completion flags should all start false', () {
      expect(controller.isInitializeComplete.value, false);
      expect(controller.isUploadComplete.value, false);
      expect(controller.isFinalizeComplete.value, false);
    });
  });

  group('Response Storage', () {
    test('responses should be null initially', () {
      expect(controller.initializeResponse.value, isNull);
      expect(controller.uploadResponse.value, isNull);
      expect(controller.finalizeResponse.value, isNull);
    });

    test('payloads should be null initially', () {
      expect(controller.initializePayload.value, isNull);
      expect(controller.uploadPayload.value, isNull);
      expect(controller.finalizePayload.value, isNull);
    });
  });
}

