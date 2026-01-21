import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';

/// Dialog to choose between SDK Camera and Pick File (mobile only)
class AddFileDialog extends StatelessWidget {
  final VoidCallback onSdkCamera;
  final VoidCallback onPickFile;

  const AddFileDialog({
    super.key,
    required this.onSdkCamera,
    required this.onPickFile,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      title: Text(
        'Add File',
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
              icon: Icons.camera_alt_rounded,
              title: 'SDK Camera',
              subtitle: 'Capture photos and videos using SDK camera',
              onTap: () {
                Navigator.of(context).pop();
                onSdkCamera();
              },
            ),
            const SizedBox(height: 16),
            _buildOption(
              icon: Icons.folder_rounded,
              title: 'Pick File',
              subtitle: 'Select files from device storage',
              onTap: () {
                Navigator.of(context).pop();
                onPickFile();
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
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
