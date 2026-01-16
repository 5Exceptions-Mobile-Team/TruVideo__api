import 'dart:typed_data';

/// Stub implementation for non-web platforms (Mobile/Desktop)
/// This should technically not be reached if guard clauses are correct,
/// but provided for safety.
class BlobUrlHelper {
  static String createBlobUrl(Uint8List bytes, {String? mimeType}) {
    throw UnimplementedError('Blob URLs are only supported on Web');
  }

  static void revokeBlobUrl(String url) {
    // No-op on mobile
  }

  static Future<Uint8List?> generateVideoThumbnail(Uint8List bytes) async {
    // Mobile uses video_thumbnail package natively
    return null;
  }
}
