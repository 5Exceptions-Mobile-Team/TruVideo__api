import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/core/services/web_media_storage_service.dart';
import 'package:media_upload_sample_app/core/utils/blob_url_helper.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewScreen extends StatefulWidget {
  final String filePath;

  const VideoPreviewScreen({super.key, required this.filePath});

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  final WebMediaStorageService _webStorage = WebMediaStorageService();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    _initializePlayer();
    super.initState();
  }

  Future<void> _initializePlayer() async {
    try {
      if (kIsWeb && widget.filePath.startsWith('web_media_')) {
        // Handle Web Video
        // On web, video_player can play from network (blob URL) or asset.
        // Since we have bytes in Hive, we need to create a Blob URL or similar.
        // However, video_player_web might not support playing directly from bytes easily without a URL.
        // A common workaround for bytes on web is creating a Blob URL.
        // But for this sample, if we can't easily get a URL, we might need to rely on the fact
        // that maybe we can get a blob URL from the bytes.

        // Actually, WebMediaStorageService stores bytes.
        // Let's see if we can get a URL. If not, this might be tricky on web without extra steps.
        // For now, let's assume we can't easily play bytes on web without creating a Blob URL,
        // which requires 'dart:html' or 'package:web'.
        // Let's try to fetch bytes and create a Blob URL if possible, or
        // if the filePath was actually a URL from the start (which it isn't here).

        // Simplified approach for this task:
        // We will try to use the network constructor if we had a URL.
        // Since we have bytes, we'll try to use a data URI if the video is small enough,
        // or just show a message that web playback from memory requires Blob URL (which we can implement if needed).

        // Let's try to implement Blob URL creation for Web.
        // We need to import 'dart:html' if kIsWeb, but conditional imports are annoying in single file.
        // We will just show a placeholder for Web Bytes video for now unless we added universal_html.
        // Wait, I see 'html' package was added in the pub add command output (transitive dependency).
        // I can try to use it? No, better to stick to safe implementation.

        // If it's a real file path on web (e.g. from file picker), video_player might handle it?
        // But here we have 'web_media_...' which is our custom ID.

        // Let's Check if we can get the bytes and provide a meaningful error or handled way.
        final id = widget.filePath.replaceFirst('web_media_', '');
        final bytes = await _webStorage.getMediaBytes(id);

        if (bytes != null) {
          // Use BlobUrlHelper to create a temporary URL instantly from bytes.
          // This avoids the expensive Base64 encoding + Data URI creation which freezes the UI.
          final blobUrl = BlobUrlHelper.createBlobUrl(bytes);
          _videoPlayerController = VideoPlayerController.networkUrl(
            Uri.parse(blobUrl),
          );

          // Note: The controller will hold the URL roughly until disposed.
          // We should ideally revoke it, but video_player might need it.
          // We can let garbage collection handle it or just leave it for this session.
          // For valid cleanup, we could wrap dispose.
        } else {
          throw Exception("Could not load video data");
        }
      } else {
        // Mobile/Desktop File
        _videoPlayerController = VideoPlayerController.file(
          File(widget.filePath),
        );
      }

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        allowFullScreen: false,
        allowMuting: false,
        showOptions: false,
        allowPlaybackSpeedChanging: false,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error initializing video player: $e");
      }
      setState(() {
        _isLoading = false;
        _errorMessage = "Could not play video: $e";
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Semantics(
          identifier: 'back',
          label: 'back',
          child: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, color: Colors.white, size: 30),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : _errorMessage != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                )
              : Chewie(controller: _chewieController!),
        ),
      ),
    );
  }
}
