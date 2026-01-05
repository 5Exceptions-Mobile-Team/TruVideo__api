import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/core/services/web_media_storage_service.dart';

class ImagePreviewScreen extends StatefulWidget {
  final String filePath;

  const ImagePreviewScreen({super.key, required this.filePath});

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  final WebMediaStorageService _webStorage = WebMediaStorageService();

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
      body: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    if (kIsWeb && widget.filePath.startsWith('web_media_')) {
      return FutureBuilder<Uint8List?>(
        future: _webStorage.getMediaBytes(
          widget.filePath.replaceFirst('web_media_', ''),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(color: Colors.white);
          }
          if (snapshot.hasData && snapshot.data != null) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return _buildErrorWidget();
              },
            );
          }
          return _buildErrorWidget();
        },
      );
    } else {
      return Image.file(
        File(widget.filePath),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    }
  }

  Widget _buildErrorWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.broken_image, color: Colors.white, size: 50),
        const SizedBox(height: 10),
        const Text(
          'Could not load image',
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
