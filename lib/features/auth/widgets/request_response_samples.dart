import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/auth/controller/auth_controller.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/enhanced_json_viewer_widget.dart';

class RequestResponseSamples extends StatefulWidget {
  const RequestResponseSamples({super.key});

  @override
  State<RequestResponseSamples> createState() => _RequestResponseSamplesState();
}

class _RequestResponseSamplesState extends State<RequestResponseSamples> {
  bool _requestExpanded = true;
  bool _responseExpanded = true;

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Request Sample Section
        Container(
          decoration: BoxDecoration(
            color: Pallet.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Pallet.primaryColor.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () =>
                    setState(() => _requestExpanded = !_requestExpanded),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Pallet.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.send_rounded,
                          color: Pallet.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() {
                          final hasRequest =
                              authController.requestBody.value != null;
                          return Text(
                            hasRequest ? 'REQUEST' : 'REQUEST SAMPLE',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Pallet.textPrimary,
                              letterSpacing: 1.0,
                            ),
                          );
                        }),
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
        Container(
          decoration: BoxDecoration(
            color: Pallet.cardBackgroundAlt,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Pallet.successColor.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () =>
                    setState(() => _responseExpanded = !_responseExpanded),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Pallet.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.check_circle_outline_rounded,
                          color: Pallet.successColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() {
                          final hasResponse =
                              authController.backOfficeAuthResponse.value !=
                              null;
                          return Row(
                            children: [
                              Text(
                                hasResponse ? 'RESPONSE' : 'RESPONSE SAMPLE',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Pallet.textPrimary,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              if (hasResponse) ...[
                                const SizedBox(width: 12),
                                Obx(() {
                                  final statusCode = authController.loginStatusCode.value;
                                  final statusCodeStr = statusCode?.toString() ?? '200';
                                  final isSuccess = statusCode != null && statusCode >= 200 && statusCode < 300;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSuccess
                                          ? Pallet.successColor.withOpacity(0.1)
                                          : Pallet.errorColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      statusCodeStr,
                                      style: GoogleFonts.firaCode(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isSuccess
                                            ? Pallet.successColor
                                            : Pallet.errorColor,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ],
                          );
                        }),
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
    final baseUrl = 'https://sdk-mobile-api.truvideo.com';
    final endpoint = '$baseUrl/api/login';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
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
        _buildSectionTitle('API Call Example'),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Pallet.glassBorder, width: 1),
          ),
          child: SelectableText(
            '''POST $endpoint

Headers:
  x-authentication-api-key: YOUR_API_KEY
  x-multitenant-external-id: YOUR_EXTERNAL_ID
  x-authentication-signature: GENERATED_SIGNATURE
  Content-Type: application/json

Body:
  {
    "timestamp": "2024-09-06T05:36:25.966Z"
  }''',
            style: GoogleFonts.firaCode(
              fontSize: 13,
              color: const Color(0xFFD4D4D4),
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultResponseSample() {
    final defaultResponse = {
      'accessToken': 'eyJhbfIWOJnewIUzI1NiJ9.eWIiOiJhZG1pbiIs...',
      'refreshToken': 'eyJhbfIWOJnewIUzI1NiJ9.eiOiJhZG1pbiIsIm...',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
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
      ],
    );
  }

  Widget _buildRequestDisplay(AuthController authController) {
    final headers = authController.requestHeaders.value ?? {};
    final body = authController.requestBody.value ?? {};
    final endpoint = authController.apiEndpoint.value;

    if (endpoint.isEmpty || headers.isEmpty || body.isEmpty) {
      return _buildEmptyState('No request data available.');
    }

    // Build a formatted code example
    final codeExample = _buildCodeExample(endpoint, headers, body);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('API Call Example'),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Pallet.glassBorder, width: 1),
          ),
          child: SelectableText(
            codeExample,
            style: GoogleFonts.firaCode(
              fontSize: 13,
              color: const Color(0xFFD4D4D4),
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  String _buildCodeExample(
    String endpoint,
    Map<String, String> headers,
    Map<String, dynamic> body,
  ) {
    final buffer = StringBuffer();

    // Method and URL
    buffer.writeln('POST $endpoint');
    buffer.writeln('');

    // Headers
    buffer.writeln('Headers:');
    headers.forEach((key, value) {
      buffer.writeln('  $key: $value');
    });
    buffer.writeln('');

    // Body
    buffer.writeln('Body:');
    final jsonBody = jsonEncode(body);
    // Format JSON with indentation
    try {
      final decoded = jsonDecode(jsonBody);
      final formatted = const JsonEncoder.withIndent('  ').convert(decoded);
      buffer.writeln(formatted);
    } catch (e) {
      buffer.writeln('  $jsonBody');
    }

    return buffer.toString();
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
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
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
                child: Semantics(
                  identifier: 'authentication_successful',
                  label: 'authentication_successful',
                  child: Text(
                    'Authentication Successful!',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
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
}
