import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

/// Web implementation using dart:html
class BlobUrlHelper {
  static String createBlobUrl(Uint8List bytes) {
    final blob = html.Blob([bytes]);
    return html.Url.createObjectUrlFromBlob(blob);
  }

  static void revokeBlobUrl(String url) {
    html.Url.revokeObjectUrl(url);
  }

  static Future<Uint8List?> generateVideoThumbnail(Uint8List bytes) async {
    try {
      final blobUrl = createBlobUrl(bytes);
      final video = html.VideoElement()
        ..src = blobUrl
        ..crossOrigin = 'anonymous'
        ..muted = true; // Required to autoplay/load in some contexts

      // Wait for metadata to load (duration, dimensions)
      await video.onLoadedMetadata.first;

      // Seek to 1 second or 50% if shorter
      double seekTime = 1.0;
      if (video.duration.isFinite && video.duration < 2.0) {
        seekTime = video.duration / 2;
      }
      video.currentTime = seekTime;

      // Wait for the seek to complete
      await video.onSeeked.first;

      // Create canvas to draw frame
      final canvas = html.CanvasElement(
        width: video.videoWidth,
        height: video.videoHeight,
      );
      final ctx = canvas.context2D;

      // Draw video frame to canvas
      ctx.drawImage(video, 0, 0);

      // Convert to blob/bytes
      final dataUrl = canvas.toDataUrl('image/jpeg', 0.75); // 75% quality
      final base64Data = dataUrl.split(',').last;

      // Cleanup
      revokeBlobUrl(blobUrl);
      video.remove();
      canvas.remove();

      return base64Decode(base64Data);
    } catch (e) {
      if (kDebugMode) {
        print('Error generating web thumbnail: $e');
      }
      return null;
    }
  }
}
