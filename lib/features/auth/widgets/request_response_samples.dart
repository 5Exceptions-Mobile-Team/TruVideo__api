import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/core/utils/utils.dart';
import 'package:media_upload_sample_app/features/auth/controller/auth_controller.dart';
import 'package:media_upload_sample_app/features/common/widgets/glass_container.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/enhanced_json_viewer_widget.dart';

class RequestResponseSamples extends StatefulWidget {
  const RequestResponseSamples({super.key});

  @override
  State<RequestResponseSamples> createState() => _RequestResponseSamplesState();
}

class _RequestResponseSamplesState extends State<RequestResponseSamples> {
  bool _requestExpanded = false;
  bool _responseExpanded = false;

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Request Sample Section
        GlassContainer(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              InkWell(
                onTap: () => setState(() => _requestExpanded = !_requestExpanded),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'REQUEST SAMPLE',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Pallet.textPrimary,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _requestExpanded ? 0.5 : 0,
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
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Obx(() {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        if (authController.requestBody.value == null)
                          _buildDefaultRequestSample(authController)
                        else
                          _buildRequestDisplay(authController),
                      ],
                    );
                  }),
                ),
                crossFadeState: _requestExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Response Sample Section
        GlassContainer(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              InkWell(
                onTap: () => setState(() => _responseExpanded = !_responseExpanded),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.check_circle_outline_rounded,
                          color: Colors.green[700],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'RESPONSE SAMPLE',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Pallet.textPrimary,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _responseExpanded ? 0.5 : 0,
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
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Obx(() {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        if (authController.backOfficeAuthResponse.value == null)
                          _buildDefaultResponseSample()
                        else
                          _buildResponseDisplay(authController),
                      ],
                    );
                  }),
                ),
                crossFadeState: _responseExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Pallet.textSecondary,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDefaultRequestSample(AuthController authController) {
    final baseUrl = authController.homeController.testingMode.value
        ? 'https://sdk-mobile-api-rc.truvideo.com'
        : 'https://sdk-mobile-api.truvideo.com';
    final endpoint = '$baseUrl/api/login';
    
    final defaultCurl = '''curl --location '$endpoint' \\
--header 'x-authentication-api-key: YOUR_API_KEY' \\
--header 'x-multitenant-external-id: YOUR_EXTERNAL_ID' \\
--header 'x-authentication-signature: GENERATED_SIGNATURE' \\
--header 'Content-Type: application/json' \\
--data '{"timestamp": "2024-09-06T05:36:25.966Z"}' ''';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.blue.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: Colors.blue[700],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Example Request - Fill in your credentials and click "Try it" to see the actual request',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('cURL Command'),
        const SizedBox(height: 8),
        _buildCodeBlock(defaultCurl),
        const SizedBox(height: 16),
        _buildSectionTitle('Request Body'),
        const SizedBox(height: 8),
        EnhancedJsonViewerWidget(
          jsonData: {'timestamp': '2024-09-06T05:36:25.966Z'},
          title: '',
          isDark: true,
        ),
        const SizedBox(height: 8),
        _buildCopyButton(
          'Copy Example cURL',
          () {
            Clipboard.setData(ClipboardData(text: defaultCurl));
            Utils.showToast('Example cURL copied to clipboard');
          },
        ),
      ],
    );
  }

  Widget _buildDefaultResponseSample() {
    final defaultResponse = {
      'accessToken': 'eyJhbfIWOJnewIUzI1NiJ9.eWIiOiJhZG1pbiIsImV4cCI6MTcyMTEzNjc0MCwiYXV0aCI6IkFETUlOIEJBQ0tPRkZJQ0UiLCJpYXQiOjE3MjEwNTAzNDAsImRldmljZUlkIjoiLTEifQ.bosYs82RrGsqx6we_MFrcebIhh6d5hUMWaecbCiySDU',
      'refreshToken': 'eyJhbfIWOJnewIUzI1NiJ9.eiOiJhZG1pbiIsImV4cCI6MTcyMTY1NTE0MCwiYXV0aCI6IkFETUlOIEJBQ0tPRkZJQ0UiLCJpYXQiOjE3MjEwNTAzNDAsImRldmljZUlkIjoiLTEifQ.77odDiZJ7CWjGHM7yNSRU4b8ycqzkPzPwUKXi0aEAOU',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.blue.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: Colors.blue[700],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Example Response - This is what you\'ll receive after successful authentication',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        EnhancedJsonViewerWidget(
          jsonData: defaultResponse,
          title: 'Response Body',
          isDark: true,
        ),
        const SizedBox(height: 8),
        _buildCopyButton(
          'Copy Example Response',
          () {
            Clipboard.setData(
              ClipboardData(text: jsonEncode(defaultResponse)),
            );
            Utils.showToast('Example response copied to clipboard');
          },
        ),
      ],
    );
  }

  Widget _buildRequestDisplay(AuthController authController) {
    final headers = authController.requestHeaders.value ?? {};
    final body = authController.requestBody.value ?? {};
    final endpoint = authController.apiEndpoint.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Endpoint
        if (endpoint.isNotEmpty) ...[
          _buildSectionTitle('Endpoint'),
          const SizedBox(height: 8),
          _buildCodeBlock(endpoint),
          const SizedBox(height: 16),
        ],
        
        // Headers
        if (headers.isNotEmpty) ...[
          _buildSectionTitle('Headers'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Pallet.glassBorder,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: headers.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: GoogleFonts.firaCode(
                            fontSize: 11,
                            color: Pallet.primaryColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          ':',
                          style: GoogleFonts.firaCode(
                            fontSize: 11,
                            color: Pallet.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          entry.value.length > 50
                              ? '${entry.value.substring(0, 50)}...'
                              : entry.value,
                          style: GoogleFonts.firaCode(
                            fontSize: 11,
                            color: Pallet.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: entry.value));
                          Utils.showToast('Copied to clipboard');
                        },
                        icon: Icon(
                          Icons.copy_rounded,
                          size: 14,
                          color: Pallet.textSecondary,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Request Body
        if (body.isNotEmpty) ...[
          _buildSectionTitle('Request Body'),
          const SizedBox(height: 8),
          EnhancedJsonViewerWidget(
            jsonData: body,
            title: '',
            isDark: true,
          ),
          const SizedBox(height: 8),
          _buildCopyButton(
            'Copy Request as cURL',
            () => _copyAsCurl(endpoint, headers, body),
          ),
        ],
      ],
    );
  }

  Widget _buildResponseDisplay(AuthController authController) {
    final response = authController.backOfficeAuthResponse.value;
    
    if (response == null) {
      return _buildEmptyState('No response data available.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.green.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: Colors.green[700],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Authentication Successful!',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        EnhancedJsonViewerWidget(
          jsonData: response,
          title: 'Response Body',
          isDark: true,
        ),
        const SizedBox(height: 8),
        _buildCopyButton(
          'Copy Response JSON',
          () {
            Clipboard.setData(
              ClipboardData(text: jsonEncode(response)),
            );
            Utils.showToast('Response copied to clipboard');
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Pallet.textSecondary,
      ),
    );
  }

  Widget _buildCodeBlock(String code) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Pallet.glassBorder,
          width: 1,
        ),
      ),
      child: SelectableText(
        code,
        style: GoogleFonts.firaCode(
          fontSize: 12,
          color: Pallet.primaryColor,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildCopyButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.blue.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.copy_rounded,
              size: 16,
              color: Colors.blue[700],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyAsCurl(String endpoint, Map<String, String> headers, Map<String, dynamic> body) {
    final buffer = StringBuffer();
    buffer.writeln("curl --location '$endpoint' \\");
    
    headers.forEach((key, value) {
      buffer.writeln("--header '$key: $value' \\");
    });
    
    buffer.writeln("--header 'Content-Type: application/json' \\");
    
    final jsonBody = jsonEncode(body);
    buffer.write("--data '$jsonBody'");
    
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    Utils.showToast('Copied as cURL command');
  }
}
