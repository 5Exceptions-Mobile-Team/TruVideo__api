import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';

/// iOS-only dialog to choose between picking photos/video or audio/document
class IosFilePickerDialog extends StatelessWidget {
  final VoidCallback onPickPhotosVideo;
  final VoidCallback onPickAudioDocument;

  const IosFilePickerDialog({
    super.key,
    required this.onPickPhotosVideo,
    required this.onPickAudioDocument,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Select File Type',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Pallet.textPrimary,
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOption(
              icon: Icons.photo_library_rounded,
              title: 'Pick Photos/Video',
              subtitle: 'Select images or video files',
              onTap: () {
                Navigator.of(context).pop();
                onPickPhotosVideo();
              },
            ),
            const SizedBox(height: 16),
            _buildOption(
              icon: Icons.audiotrack_rounded,
              title: 'Pick Audio/Document',
              subtitle: 'Select audio files or documents',
              onTap: () {
                Navigator.of(context).pop();
                onPickAudioDocument();
              },
            ),
          ],
        ),
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: false,
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Pallet.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Pallet.cardBackgroundAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Pallet.glassBorder, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Pallet.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Pallet.primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Pallet.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Pallet.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Pallet.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
