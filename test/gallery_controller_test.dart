import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/features/gallery/controller/gallery_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GalleryController controller;

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async => '/tmp',
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
    controller = GalleryController();
  });

  tearDown(() {
    Get.reset();
  });

  group('GalleryController Initialization', () {
    test('should initialize with empty lists', () {
      expect(controller.allMediaPaths, isEmpty);
      expect(controller.imagePaths, isEmpty);
      expect(controller.videoPaths, isEmpty);
      expect(controller.audioPaths, isEmpty);
      expect(controller.documentPaths, isEmpty);
    });

    test('should initialize with default values', () {
      expect(controller.autoClose, false);
      expect(controller.selectEnabled.value, false);
      expect(controller.selectedMedia, isEmpty);
    });
  });

  group('getMediaType', () {
    test('should return IMAGE for image extensions', () {
      expect(controller.getMediaType('photo.png'), 'IMAGE');
      expect(controller.getMediaType('photo.jpeg'), 'IMAGE');
      expect(controller.getMediaType('photo.jpg'), 'IMAGE');
      expect(controller.getMediaType('photo.JPG'), 'IMAGE');
    });

    test('should return VIDEO for video extensions', () {
      expect(controller.getMediaType('video.mp4'), 'VIDEO');
      expect(controller.getMediaType('video.mov'), 'VIDEO');
      expect(controller.getMediaType('video.mkv'), 'VIDEO');
      expect(controller.getMediaType('video.webm'), 'VIDEO');
    });

    test('should return AUDIO for audio extensions', () {
      expect(controller.getMediaType('audio.mp3'), 'AUDIO');
      expect(controller.getMediaType('audio.aac'), 'AUDIO');
      expect(controller.getMediaType('audio.wav'), 'AUDIO');
      expect(controller.getMediaType('audio.m4a'), 'AUDIO');
    });

    test('should return DOCUMENT for document extensions', () {
      expect(controller.getMediaType('doc.pdf'), 'DOCUMENT');
      expect(controller.getMediaType('doc.doc'), 'DOCUMENT');
      expect(controller.getMediaType('doc.docx'), 'DOCUMENT');
      expect(controller.getMediaType('doc.txt'), 'DOCUMENT');
    });

    test('should return UNKNOWN for unknown extensions', () {
      expect(controller.getMediaType('file.xyz'), 'UNKNOWN');
      expect(controller.getMediaType('file.bin'), 'UNKNOWN');
    });
  });

  group('getMediaList', () {
    test('should return imagePaths for type 1', () {
      controller.imagePaths.add('image.jpg');
      expect(controller.getMediaList('1'), controller.imagePaths);
    });

    test('should return videoPaths for type 2', () {
      controller.videoPaths.add('video.mp4');
      expect(controller.getMediaList('2'), controller.videoPaths);
    });

    test('should return audioPaths for type 3', () {
      controller.audioPaths.add('audio.mp3');
      expect(controller.getMediaList('3'), controller.audioPaths);
    });

    test('should return documentPaths for type 4', () {
      controller.documentPaths.add('doc.pdf');
      expect(controller.getMediaList('4'), controller.documentPaths);
    });

    test('should return allMediaPaths for type 0', () {
      expect(controller.getMediaList('0'), controller.allMediaPaths);
    });
  });

  group('enableDisableSelection', () {
    test('should toggle selectEnabled', () {
      expect(controller.selectEnabled.value, false);

      controller.enableDisableSelection();
      expect(controller.selectEnabled.value, true);

      controller.enableDisableSelection();
      expect(controller.selectEnabled.value, false);
    });

    test('should clear selectedMedia when toggling', () {
      controller.selectedMedia.add('path1');
      controller.selectedMedia.add('path2');

      controller.enableDisableSelection();

      expect(controller.selectedMedia, isEmpty);
    });
  });

  group('formatDate', () {
    test('should return empty string for null date', () {
      expect(controller.formatDate(null), '');
    });

    test('should return empty string for empty date', () {
      expect(controller.formatDate(''), '');
    });

    test('should format valid date string', () {
      final result = controller.formatDate('2024-01-15 14:30:00');
      expect(result, isNotEmpty);
      expect(result, contains('Jan'));
      expect(result, contains('15'));
      expect(result, contains('2024'));
    });

    test('should return empty string for invalid date', () {
      expect(controller.formatDate('invalid-date'), '');
    });
  });

  group('updateMediaList', () {
    test('should add image path to imagePaths', () {
      controller.updateMediaList('/path/to/image.jpg');
      expect(controller.imagePaths, contains('/path/to/image.jpg'));
    });

    test('should add video path to videoPaths', () {
      controller.updateMediaList('/path/to/video.mp4');
      expect(controller.videoPaths, contains('/path/to/video.mp4'));
    });

    test('should not add thumbnail images', () {
      controller.updateMediaList('/path/to/thumbnail_image.jpg');
      expect(controller.imagePaths, isEmpty);
    });

    test('should not add edited videos', () {
      controller.updateMediaList('/path/to/edited_video.mp4');
      expect(controller.videoPaths, isEmpty);
    });
  });
}
