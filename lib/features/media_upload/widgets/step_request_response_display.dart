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
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF45475A),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF11111B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF45475A),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusCodeColor(statusCode!).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        statusCode!,
                        style: GoogleFonts.firaCode(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getStatusCodeColor(statusCode!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        statusMessage!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (statusCode != null && statusMessage != null)
              const SizedBox(height: 12),
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

  Color _getStatusCodeColor(String code) {
    final codeNum = int.tryParse(code) ?? 200;
    if (codeNum >= 200 && codeNum < 300) {
      return Pallet.successColor;
    } else if (codeNum >= 300 && codeNum < 400) {
      return Colors.orange;
    } else if (codeNum >= 400) {
      return Pallet.errorColor;
    }
    return Pallet.textSecondary;
  }
}
