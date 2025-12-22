import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:media_upload_sample_app/features/gallery/models/media_item_model.dart';

class WebMediaStorageService {
  static final WebMediaStorageService _instance = WebMediaStorageService._internal();
  factory WebMediaStorageService() => _instance;

  Box<MediaItemModel>? _mediaBox;
  static const String _boxName = 'web_media_box';

  WebMediaStorageService._internal();

  Future<void> init() async {
    if (kIsWeb) {
      try {
        _mediaBox = await Hive.openBox<MediaItemModel>(_boxName);
      } catch (e) {
        if (kDebugMode) {
          print('Error opening web media box: $e');
        }
      }
    }
  }

  bool get isInitialized => _mediaBox != null;

  Future<String> saveMedia({
    required String fileName,
    required String mediaType,
    required Uint8List fileBytes,
  }) async {
    if (!kIsWeb || _mediaBox == null) {
      throw Exception('WebMediaStorageService is only available on web');
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();

    final mediaItem = MediaItemModel(
      id: id,
      fileName: fileName,
      mediaType: mediaType,
      fileBytes: fileBytes.toList(),
      fileSize: fileBytes.length,
      createdAt: now,
      modifiedAt: now,
    );

    await _mediaBox!.put(id, mediaItem);
    return mediaItem.displayPath;
  }

  Future<Uint8List?> getMediaBytes(String id) async {
    if (!kIsWeb || _mediaBox == null) {
      return null;
    }

    final mediaItem = _mediaBox!.get(id);
    if (mediaItem != null) {
      return Uint8List.fromList(mediaItem.fileBytes);
    }
    return null;
  }

  List<MediaItemModel> getAllMedia() {
    if (!kIsWeb || _mediaBox == null) {
      return [];
    }
    return _mediaBox!.values.toList();
  }

  Future<void> deleteMedia(String id) async {
    if (!kIsWeb || _mediaBox == null) {
      return;
    }
    await _mediaBox!.delete(id);
  }

  Future<void> deleteAllMedia() async {
    if (!kIsWeb || _mediaBox == null) {
      return;
    }
    await _mediaBox!.clear();
  }

  Future<void> close() async {
    await _mediaBox?.close();
  }
}

