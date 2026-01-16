import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/core/services/web_media_storage_service.dart';
import 'package:media_upload_sample_app/core/utils/blob_url_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfPreviewWidget extends StatelessWidget {
  final String filePath;
  final double height;
  final bool showOpenButton;

  const PdfPreviewWidget({
    super.key,
    required this.filePath,
    this.height = 250,
    this.showOpenButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E40AF).withOpacity(0.9),
            const Color(0xFF1E3A8A).withOpacity(0.8),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Colors.white,
                  size: 45,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'PDF Document',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              if (showOpenButton) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _openPdf(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.open_in_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Open PDF',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          // Open button overlay
          // if (showOpenButton)
          //   Positioned(
          //     bottom: 12,
          //     right: 12,
          //     child: Container(
          //       padding: const EdgeInsets.all(8),
          //       decoration: BoxDecoration(
          //         color: Colors.black.withOpacity(0.6),
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //       child: const Icon(
          //         Icons.open_in_full,
          //         color: Colors.white,
          //         size: 20,
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }

  Future<void> _openPdf(BuildContext context) async {
    try {
      if (kIsWeb && filePath.startsWith('web_media_')) {
        final webStorage = WebMediaStorageService();
        final id = filePath.replaceFirst('web_media_', '');
        final bytes = await webStorage.getMediaBytes(id);
        if (bytes != null) {
          // Create blob URL with PDF MIME type and open in new tab
          final url = BlobUrlHelper.createBlobUrl(bytes, mimeType: 'application/pdf');
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        }
      } else {
        // For mobile/desktop, try to open with system default app
        final file = File(filePath);
        if (await file.exists()) {
          // Use url_launcher or platform-specific method
          // For now, show a message
          Get.snackbar(
            'PDF',
            'Opening PDF file...',
            backgroundColor: Pallet.primaryColor,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open PDF file',
        backgroundColor: Pallet.errorColor,
        colorText: Colors.white,
      );
    }
  }
}
