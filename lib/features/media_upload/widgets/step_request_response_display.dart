import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/enhanced_json_viewer_widget.dart';

class StepRequestResponseDisplay extends StatelessWidget {
  final Map<String, dynamic>? requestPayload;
  final Map<String, dynamic>? responseData;
  final String requestMethod;
  final String endpoint;
  final Map<String, String>? requestHeaders;
  final String? statusCode;
  final String? statusMessage;
  final int? stepNumber;

  const StepRequestResponseDisplay({
    super.key,
    this.requestPayload,
    this.responseData,
    required this.requestMethod,
    required this.endpoint,
    this.requestHeaders,
    this.statusCode,
    this.statusMessage,
    this.stepNumber,
  });

  @override
  Widget build(BuildContext context) {
    if (responseData == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Pallet.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Pallet.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (responseData != null) ...[
            if (statusCode != null && statusMessage != null)
              _buildStatusCodeContainer(statusCode!, statusMessage!),
            if (statusCode != null && statusMessage != null)
              const SizedBox(height: 16),
            EnhancedJsonViewerWidget(
              jsonData: responseData!,
              isDark: true,
              title: 'Response',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCodeContainer(String statusCode, String statusMessage) {
    final statusColor = _getStatusCodeColor(statusCode);
    final codeNum = int.tryParse(statusCode) ?? 200;

    // Determine background color based on status code
    Color backgroundColor;
    Color borderColor;

    if (codeNum >= 200 && codeNum < 300) {
      // Success - light green tint
      backgroundColor = Pallet.successColor.withOpacity(0.08);
      borderColor = Pallet.successColor.withOpacity(0.3);
    } else if (codeNum >= 300 && codeNum < 400) {
      // Warning - light orange/amber tint
      backgroundColor = Pallet.warningColor.withOpacity(0.08);
      borderColor = Pallet.warningColor.withOpacity(0.3);
    } else if (codeNum >= 400) {
      // Error - light red tint
      backgroundColor = Pallet.errorColor.withOpacity(0.08);
      borderColor = Pallet.errorColor.withOpacity(0.3);
    } else {
      // Default - subtle grey
      backgroundColor = Pallet.cardBackgroundSubtle;
      borderColor = Pallet.glassBorder;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              statusCode,
              style: GoogleFonts.firaCode(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              statusMessage,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Pallet.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusCodeColor(String code) {
    final codeNum = int.tryParse(code) ?? 200;
    if (codeNum >= 200 && codeNum < 300) {
      return Pallet.successColor;
    } else if (codeNum >= 300 && codeNum < 400) {
      return Pallet.warningColor;
    } else if (codeNum >= 400) {
      return Pallet.errorColor;
    }
    return Pallet.textSecondary;
  }
}
