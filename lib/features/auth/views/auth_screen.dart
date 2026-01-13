import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/auth/controller/auth_controller.dart';
import 'package:media_upload_sample_app/features/auth/views/credentials_screen.dart';
import 'package:media_upload_sample_app/features/auth/widgets/api_flow_explainer.dart';
import 'package:media_upload_sample_app/features/auth/widgets/authenticate_card.dart';
import 'package:media_upload_sample_app/features/auth/widgets/authenticated_widget.dart';
// import 'package:media_upload_sample_app/features/auth/widgets/api_request_display.dart'; // Removed
import 'package:media_upload_sample_app/features/auth/widgets/parameter_info_card.dart';
import 'package:media_upload_sample_app/features/common/widgets/app_button.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_app_bar.dart';
import 'package:media_upload_sample_app/features/common/widgets/generic_api_request_display.dart';
import 'package:media_upload_sample_app/features/common/widgets/gradient_background.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/enhanced_json_viewer_widget.dart';

class AuthScreen extends StatefulWidget {
  final bool isAuthenticated;
  const AuthScreen({super.key, required this.isAuthenticated});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late AuthController authController;

  @override
  void initState() {
    authController = Get.put(AuthController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CommonAppBar(
          title: 'Authentication',
          leading: Semantics(
            identifier: 'back_button',
            label: 'back_button',
            child: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
        ),
        body: SafeArea(
          child: Obx(
            () => SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Credentials History Button
                  Semantics(
                    identifier: 'saved_credentials',
                    label: 'saved_credentials',
                    child: AppButton(
                      text: 'Saved Credentials',
                      onTap: () => Get.to(() => CredentialsScreen()),
                      backgroundColor: Pallet.primaryDarkColor,
                      buttonIcon: const Icon(
                        Icons.history,
                        color: Colors.white,
                      ),
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.5),
                  const SizedBox(height: 24),

                  // API Flow Explainer - Educational Section
                  const ApiFlowExplainer()
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .slideY(begin: 0.1),
                  const SizedBox(height: 16),

                  // Parameter Info Card - Expandable Explanations
                  const ParameterInfoCard()
                      .animate()
                      .fadeIn(delay: 300.ms)
                      .slideY(begin: 0.1),
                  const SizedBox(height: 24),

                  if (authController.homeController.enableTruVideoSdk) ...[
                    _buildSeparator(
                      'Back Office Authentication',
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 16),
                  ],

                  // Authentication Form or Success Widget
                  authController.homeController.boAuthenticated.value
                      ? AuthenticatedWidget(
                          title: 'Back Office Authenticated',
                          onClear: () {
                            authController.homeController.clearBackOfficeAuth();
                            authController.resetDisplayData();
                          },
                        ).animate().fadeIn(delay: 500.ms).scale()
                      : AuthenticateCard(
                          title: 'Authenticate',
                          forBackOffice: true,
                        ).animate().fadeIn(delay: 500.ms).slideX(),

                  if (authController.homeController.enableTruVideoSdk) ...[
                    const SizedBox(height: 24),
                    _buildSeparator(
                      'Mobile Authentication',
                    ).animate().fadeIn(delay: 600.ms),
                    const SizedBox(height: 16),

                    authController.homeController.mobileAuthenticated.value
                        ? AuthenticatedWidget(
                            title: 'Mobile Authenticated',
                            onClear: () {
                              authController.homeController.clearMobileAuth();
                              authController.resetDisplayData();
                            },
                          ).animate().fadeIn(delay: 700.ms).scale()
                        : Column(
                            children: [
                              // PayloadCard(
                              //   title: 'Payload',
                              // ).animate().fadeIn(delay: 500.ms).slideX(),
                              // const SizedBox(height: 16),
                              // SignatureCard(
                              //   title: 'Signature',
                              // ).animate().fadeIn(delay: 600.ms).slideX(),
                              // const SizedBox(height: 16),
                              // AuthenticateCard(
                              //   title: 'Authenticate',
                              // ).animate().fadeIn(delay: 700.ms).slideX(),
                            ],
                          ),
                  ],

                  const SizedBox(height: 24),

                  // API Request Display - Shows request body and headers
                  Obx(() {
                    if (authController.requestBody.value == null) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSeparator(
                          'Request Details',
                        ).animate().fadeIn(delay: 100.ms),
                        const SizedBox(height: 16),
                        GenericApiRequestDisplay(
                          endpoint: authController.apiEndpoint.value,
                          requestHeaders:
                              authController.requestHeaders.value ?? {},
                          requestBody: authController.requestBody.value ?? {},
                        ).animate().fadeIn(),
                      ],
                    );
                  }),

                  const SizedBox(height: 20),

                  // API Response JSON Viewer
                  Obx(() {
                    if (!authController.homeController.testingMode.value ||
                        authController.backOfficeAuthResponse.value == null) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSeparator(
                          'Response Details',
                        ).animate().fadeIn(delay: 100.ms),
                        const SizedBox(height: 8),
                        // _buildResponseExplanation().animate().fadeIn(
                        //   delay: 150.ms,
                        // ),
                        EnhancedJsonViewerWidget(
                          jsonData: authController.backOfficeAuthResponse.value,
                          title: 'Response Body',
                          isDark: true,
                        ).animate().fadeIn(),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeparator(String title) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Pallet.glassBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Pallet.textSecondary,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Pallet.glassBorder)),
      ],
    );
  }

  // Widget _buildResponseExplanation() {
  //   return Container(
  //     padding: const EdgeInsets.all(12),
  //     margin: const EdgeInsets.only(bottom: 8),
  //     decoration: BoxDecoration(
  //       color: Colors.green.withValues(alpha: 0.1),
  //       borderRadius: BorderRadius.circular(10),
  //       border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
  //     ),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Icon(
  //           Icons.check_circle_outline_rounded,
  //           size: 18,
  //           color: Colors.green[700],
  //         ),
  //         const SizedBox(width: 10),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 'Authentication Successful!',
  //                 style: GoogleFonts.inter(
  //                   fontSize: 13,
  //                   fontWeight: FontWeight.w600,
  //                   color: Colors.green[700],
  //                 ),
  //               ),
  //               const SizedBox(height: 4),
  //               Text(
  //                 'The accessToken is your Bearer token. Use it in the Authorization header for all future API requests:\nAuthorization: Bearer <accessToken>',
  //                 style: GoogleFonts.inter(
  //                   fontSize: 12,
  //                   color: Pallet.textSecondary,
  //                   height: 1.4,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
