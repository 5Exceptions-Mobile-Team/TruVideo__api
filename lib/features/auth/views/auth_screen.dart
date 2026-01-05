import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/auth/controller/auth_controller.dart';
import 'package:media_upload_sample_app/features/auth/widgets/authenticate_card.dart';
import 'package:media_upload_sample_app/features/auth/widgets/authenticated_widget.dart';
import 'package:media_upload_sample_app/features/auth/widgets/payload_card.dart';
import 'package:media_upload_sample_app/features/auth/widgets/signature_card.dart';
import 'package:media_upload_sample_app/features/common/widgets/app_button.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_app_bar.dart';
import 'package:media_upload_sample_app/features/common/widgets/gradient_background.dart';
import 'package:media_upload_sample_app/features/media_upload/widgets/enhanced_json_viewer_widget.dart';
import 'credentials_screen.dart';

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
          title: 'Core Module',
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
                  Semantics(
                    identifier: 'credentials_history',
                    label: 'Credentials History Button',
                    child: AppButton(
                      text: 'Credentials History',
                      onTap: () => Get.to(() => CredentialsScreen()),
                      backgroundColor: Pallet.primaryDarkColor,
                      buttonIcon: const Icon(
                        Icons.history,
                        color: Colors.white,
                      ),
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.5),
                  const SizedBox(height: 24),

                  if (authController.homeController.enableTruVideoSdk) ...[
                    _buildSeparator(
                      'Back Office Authentication',
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 16),
                  ],

                  authController.homeController.boAuthenticated.value
                      ? AuthenticatedWidget(
                          title: 'Back Office Authenticated',
                          onClear: () => authController.homeController
                              .clearBackOfficeAuth(),
                        ).animate().fadeIn(delay: 300.ms).scale()
                      : AuthenticateCard(
                          title: 'Authenticate',
                          forBackOffice: true,
                        ).animate().fadeIn(delay: 300.ms).slideX(),

                  if (authController.homeController.enableTruVideoSdk) ...[
                    const SizedBox(height: 24),
                    _buildSeparator(
                      'Mobile Authentication',
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 16),

                    authController.homeController.mobileAuthenticated.value
                        ? AuthenticatedWidget(
                            title: 'Mobile Authenticated',
                            onClear: () =>
                                authController.homeController.clearMobileAuth(),
                          ).animate().fadeIn(delay: 500.ms).scale()
                        : Column(
                            children: [
                              PayloadCard(
                                title: 'Payload',
                              ).animate().fadeIn(delay: 500.ms).slideX(),
                              const SizedBox(height: 16),
                              SignatureCard(
                                title: 'Signature',
                              ).animate().fadeIn(delay: 600.ms).slideX(),
                              const SizedBox(height: 16),
                              AuthenticateCard(
                                title: 'Authenticate',
                              ).animate().fadeIn(delay: 700.ms).slideX(),
                            ],
                          ),
                  ],

                  const SizedBox(height: 20),
                  Obx(() {
                    if (!authController.homeController.testingMode.value ||
                        authController.backOfficeAuthResponse.value == null) {
                      return const SizedBox.shrink();
                    }
                    return EnhancedJsonViewerWidget(
                      jsonData: authController.backOfficeAuthResponse.value,
                      title: 'Back Office Auth Response',
                    ).animate().fadeIn();
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
}
