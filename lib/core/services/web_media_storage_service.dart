import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:media_upload_sample_app/features/gallery/models/media_item_model.dart';

class WebMediaStorageService {
  static final WebMediaStorageService _instance =
      WebMediaStorageService._internal();
  factory WebMediaStorageService() => _instance;

  Box<MediaItemModel>? _mediaBox; // Metadata only
  LazyBox<Uint8List>? _bytesBox; // Heavy bytes

  // Use new box names to force a fresh start and avoid crashing on old data
  static const String _boxName = 'web_media_meta_v1';
  static const String _bytesBoxName = 'web_media_bytes_v1';

  WebMediaStorageService._internal();

  Future<void> init() async {
    if (kIsWeb) {
      try {
        _mediaBox = await Hive.openBox<MediaItemModel>(_boxName);
        _bytesBox = await Hive.openLazyBox<Uint8List>(_bytesBoxName);
      } catch (e) {
        if (kDebugMode) {
          print('Error opening web media box: $e');
        }
      }
    }
  }

  bool get isInitialized => _mediaBox != null && _bytesBox != null;

  Future<String> saveMedia({
    required String fileName,
    required String mediaType,
    required Uint8List fileBytes,
  }) async {
    if (!kIsWeb || !isInitialized) {
      throw Exception('WebMediaStorageService is not initialized');
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();

    // Store empty bytes in the metadata model to keep it lightweight.
    // The actual bytes are stored in the LazyBox.
    final mediaItem = MediaItemModel(
      id: id,
      fileName: fileName,
      mediaType: mediaType,
      fileBytes: Uint8List(0), // Empty bytes to save memory in the main box
      fileSize: fileBytes.length, // Store real size
      createdAt: now,
      modifiedAt: now,
    );

    // Save metadata to standard Box (fast synchronous access)
    await _mediaBox!.put(id, mediaItem);

    // Save heavy bytes to LazyBox (async on-demand access)
    await _bytesBox!.put(id, fileBytes);

    return mediaItem.displayPath;
  }

  Future<Uint8List?> getMediaBytes(String id) async {
    if (!kIsWeb || !isInitialized) {
      return null;
    }
    // Fetch from the LazyBox
    return await _bytesBox!.get(id);
  }

  List<MediaItemModel> getAllMedia() {
    if (!kIsWeb || _mediaBox == null) {
      return [];
    }
    return _mediaBox!.values.toList();
  }

  MediaItemModel? getMediaItem(String id) {
    if (!kIsWeb || _mediaBox == null) {
      return null;
    }
    return _mediaBox!.get(id);
  }

  Future<void> deleteMedia(String id) async {
    if (!kIsWeb || !isInitialized) {
      return;
    }
    await _mediaBox!.delete(id);
    await _bytesBox!.delete(id);
  }

  Future<void> deleteAllMedia() async {
    if (!kIsWeb || !isInitialized) {
      return;
    }
    await _mediaBox!.clear();
    await _bytesBox!.clear();
  }

  Future<void> close() async {
    await _mediaBox?.close();
    await _bytesBox?.close();
  }
}
