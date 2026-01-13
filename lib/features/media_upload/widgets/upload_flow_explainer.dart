import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/common/widgets/glass_container.dart';

class UploadFlowExplainer extends StatefulWidget {
  const UploadFlowExplainer({super.key});

  @override
  State<UploadFlowExplainer> createState() => _UploadFlowExplainerState();
}

class _UploadFlowExplainerState extends State<UploadFlowExplainer> {
  bool _isExpanded = false;
  int _selectedSection = 0; // 0: Overview, 1: Technical Details

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Pallet.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.info_outline_rounded,
                      color: Pallet.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'How does uploading work?',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Pallet.textPrimary,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Pallet.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Tabs
                  _buildSectionTabs(),
                  const SizedBox(height: 20),
                  // Content based on selected section
                  if (_selectedSection == 0) _buildOverviewSection(),
                  if (_selectedSection == 1) _buildTechnicalDetailsSection(),
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Pallet.glassWhiteLow,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton('Overview', 0, Icons.dashboard_rounded),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildTabButton('How It Works', 1, Icons.settings_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index, IconData icon) {
    final isSelected = _selectedSection == index;
    return InkWell(
      onTap: () => setState(() => _selectedSection = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? Pallet.primaryColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Pallet.primaryColor : Pallet.textSecondary,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Pallet.primaryColor
                      : Pallet.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFlowStep(
          step: 1,
          icon: Icons.rocket_launch_rounded,
          title: 'Start Upload Session',
          description:
              'The server creates a secure upload session with a unique ID. It also generates a special "Pre-signed URL" that acts as a secure key, authorizing you to send your file directly to the cloud.',
          color: Colors.blue,
        ),
        _buildFlowConnector(),
        _buildFlowStep(
          step: 2,
          icon: Icons.cloud_upload_rounded,
          title: 'Secure Transfer',
          description:
              'Your file is uploaded directly to secure cloud storage (S3) using the Pre-signed URL. This bypasses the API server to ensure maximum speed and reliability, especially for large files.',
          color: Colors.orange,
        ),
        _buildFlowConnector(),
        _buildFlowStep(
          step: 3,
          icon: Icons.check_circle_rounded,
          title: 'Complete & Verify',
          description:
              'Once the file reaches the cloud, the server verifies its integrity using digital signatures (ETags). If all parts match perfectly, the upload is finalized and marked as complete.',
          color: Colors.green,
        ),
        _buildFlowConnector(),
        _buildFlowStep(
          step: 4,
          icon: Icons.refresh_rounded,
          title: 'Status Verification',
          description:
              'The upload is finalized asynchronously. The system automatically checks the status to confirm your file was successfully processed and is ready to use.',
          color: Colors.purple,
          isLast: true,
        ),
        const SizedBox(height: 20),
        _buildInfoBox(
          icon: Icons.security_rounded,
          title: 'Security Features',
          content: [
            'Bearer Token Authentication - Your uploads are protected with secure tokens',
            'Pre-signed URLs - Temporary secure links that expire after 20 minutes',
            'Direct S3 Upload - Files never pass through intermediate servers',
            'ETag Verification - Digital signatures ensure file integrity',
          ],
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildTechnicalDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoBox(
          icon: Icons.pie_chart_rounded,
          title: 'Multipart Upload',
          content: [
            'You can split large files into smaller chunks/parts for faster, more reliable uploads',
            'Each part must be at least 5 MB (except the last part)',
            'Maximum 600 MB per part',
            'Up to 120 parts per file',
            'Parts can be uploaded in parallel for maximum speed',
          ],
          color: Colors.orange,
        ),
        const SizedBox(height: 16),
        _buildInfoBox(
          icon: Icons.schedule_rounded,
          title: 'Asynchronous Processing',
          content: [
            'After completing the upload, the system processes your file in the background',
            'Status polling is required to confirm final success or failure',
            'This allows the system to handle large files efficiently without blocking',
            'You\'ll see real-time status updates as processing completes',
          ],
          color: Colors.purple,
        ),
        const SizedBox(height: 16),
        _buildInfoBox(
          icon: Icons.verified_rounded,
          title: 'ETag Verification',
          content: [
            'Each uploaded part receives a unique ETag (digital fingerprint)',
            'ETags are MD5 hashes that verify file integrity',
            'The system compares ETags to ensure all parts uploaded correctly',
            'If any part fails verification, the upload is rejected for your safety',
          ],
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        _buildInfoBox(
          icon: Icons.link_rounded,
          title: 'Pre-signed URLs',
          content: [
            'Temporary secure URLs that grant upload permission',
            'Valid for 20 minutes after generation',
            'Direct connection to cloud storage (S3)',
            'No need to expose your API credentials',
          ],
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildInfoBox({
    required IconData icon,
    required String title,
    required List<String> content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Pallet.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...content.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Pallet.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowStep({
    required int step,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Center(child: Icon(icon, color: color, size: 18)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Step $step',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Pallet.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Pallet.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlowConnector() {
    return Padding(
      padding: const EdgeInsets.only(left: 17),
      child: Container(
        width: 2,
        height: 16,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Pallet.glassBorder,
              Pallet.glassBorder.withValues(alpha: 0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
