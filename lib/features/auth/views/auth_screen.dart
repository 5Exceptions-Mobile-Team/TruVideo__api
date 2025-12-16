import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/auth/controller/auth_controller.dart';
import 'package:media_upload_sample_app/features/auth/widgets/authenticate_card.dart';
import 'package:media_upload_sample_app/features/auth/widgets/authenticated_widget.dart';
import 'package:media_upload_sample_app/features/auth/widgets/payload_card.dart';
import 'package:media_upload_sample_app/features/auth/widgets/signature_card.dart';
import 'package:media_upload_sample_app/features/common/widgets/app_button.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_app_bar.dart';
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
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => authController.homeController.checkAuthStatus(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Core Module'),
      body: SafeArea(
        child: Obx(
          () => SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                spacing: 20,
                children: [
                  Semantics(
                    identifier: 'credentials_history',
                    label: 'Credentials History Button',
                    child: AppButton(
                      text: 'Credentials History',
                      onTap: () => Get.to(() => CredentialsScreen()),
                      backgroundColor: Pallet.secondaryDarkColor,
                    ),
                  ),
                  _buildSeparator('Back Office Authentication'),
                  authController.homeController.boAuthenticated.value
                      ? AuthenticatedWidget(
                          title: 'Back Office Authenticated',
                          onClear: () => authController.homeController
                              .clearBackOfficeAuth(),
                        )
                      : AuthenticateCard(
                          title: 'Authenticate',
                          forBackOffice: true,
                        ),
                  const Divider(),
                  _buildSeparator('Mobile Authentication'),
                  authController.homeController.mobileAuthenticated.value
                      ? AuthenticatedWidget(
                          title: 'Mobile Authenticated',
                          onClear: () =>
                              authController.homeController.clearMobileAuth(),
                        )
                      : Column(
                          spacing: 20,
                          children: [
                            PayloadCard(title: 'Payload'),
                            SignatureCard(title: 'Signature'),
                            AuthenticateCard(title: 'Authenticate'),
                          ],
                        ),
                  Obx(() {
                    // Only show JSON response if testing mode is enabled
                    if (!authController.homeController.testingMode.value) {
                      return const SizedBox.shrink();
                    }
                    return authController.backOfficeAuthResponse.value != null
                        ? EnhancedJsonViewerWidget(
                            jsonData:
                                authController.backOfficeAuthResponse.value,
                            title: 'Back Office Auth Response',
                          )
                        : const SizedBox.shrink();
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
    return Container(
      width: double.maxFinite,
      height: 50,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Pallet.secondaryBackground,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      ),
    );
  }
}
