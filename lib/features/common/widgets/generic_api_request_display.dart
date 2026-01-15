import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/utils/utils.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/enhanced_json_viewer_widget.dart';

class GenericApiRequestDisplay extends StatelessWidget {
  final String title;
  final String requestMethod;
  final String endpoint;
  final Map<String, String> requestHeaders;
  final Map<String, dynamic> requestBody;
  final bool showCopyButton;

  const GenericApiRequestDisplay({
    super.key,
    this.title = 'Request Sent',
    this.requestMethod = 'POST',
    required this.endpoint,
    required this.requestHeaders,
    required this.requestBody,
    this.showCopyButton = false,
  });

  @override
  Widget build(BuildContext context) {
    if (endpoint.isEmpty && requestHeaders.isEmpty && requestBody.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF45475A),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Pallet.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  requestMethod,
                  style: GoogleFonts.firaCode(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Pallet.successColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              if (showCopyButton)
                IconButton(
                  onPressed: () => _copyAsCurl(),
                  icon: Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: Colors.grey[400],
                  ),
                  tooltip: 'Copy as cURL',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Endpoint URL
          if (endpoint.isNotEmpty)
            _buildSection(
              title: 'Endpoint',
              icon: Icons.link_rounded,
              color: Colors.blue,
              child: _buildCodeBlock(endpoint),
            ),

          if (endpoint.isNotEmpty) const SizedBox(height: 16),

          // Headers Section
          if (requestHeaders.isNotEmpty)
            _buildSection(
              title: 'Headers',
              icon: Icons.article_rounded,
              color: Colors.orange,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: requestHeaders.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildHeaderRow(entry.key, entry.value),
                  );
                }).toList(),
              ),
            ),

          if (requestHeaders.isNotEmpty) const SizedBox(height: 16),

          // Request Body Section
          if (requestBody.isNotEmpty)
            EnhancedJsonViewerWidget(
              jsonData: requestBody,
              title: 'Request Body',
              isDark: true,
            ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildCodeBlock(String code) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF11111B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText(
        code,
        style: GoogleFonts.firaCode(
          fontSize: 12,
          color: Colors.green[300],
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildHeaderRow(String key, String value) {
    // Mask sensitive values
    String displayValue = value;
    if ((key.toLowerCase().contains('api-key') ||
            key.toLowerCase().contains('signature') ||
            key.toLowerCase().contains('auth')) &&
        value.length > 20) {
      displayValue =
          '${value.substring(0, 10)}...${value.substring(value.length - 6)}';
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF11111B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              key,
              style: GoogleFonts.firaCode(
                fontSize: 11,
                color: Colors.cyan[300],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              ':',
              style: GoogleFonts.firaCode(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              displayValue,
              style: GoogleFonts.firaCode(
                fontSize: 11,
                color: Colors.amber[300],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyAsCurl() {
    final buffer = StringBuffer();
    buffer.writeln("curl --location '$endpoint' \\");

    requestHeaders.forEach((key, value) {
      buffer.writeln("--header '$key: $value' \\");
    });

    final jsonBody = jsonEncode(requestBody);
    buffer.write("--data '$jsonBody'");

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    Utils.showToast('Copied as cURL command');
  }
}
