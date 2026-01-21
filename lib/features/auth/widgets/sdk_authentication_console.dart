import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/core/utils/utils.dart';
import 'package:media_upload_sample_app/features/auth/controller/auth_controller.dart';
import 'package:media_upload_sample_app/features/auth/models/credentials_model.dart';
import 'package:media_upload_sample_app/features/auth/views/save_update_credentials.dart';
import 'package:media_upload_sample_app/features/common/widgets/app_button.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_textfield.dart';
import 'package:media_upload_sample_app/features/home/controller/home_controller.dart';

class SdkAuthenticationConsole extends StatefulWidget {
  const SdkAuthenticationConsole({super.key});

  @override
  State<SdkAuthenticationConsole> createState() =>
      _SdkAuthenticationConsoleState();
}

class _SdkAuthenticationConsoleState extends State<SdkAuthenticationConsole> {
  @override
  void initState() {
    super.initState();
    // Check authentication status when widget is initialized
    final homeController = Get.find<HomeController>();
    homeController.checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Modern Gradient Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Pallet.primaryColor.withOpacity(0.1),
                Pallet.primaryColor.withOpacity(0.05),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Pallet.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.security_rounded,
                  color: Pallet.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Truvideo Core SDK',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Pallet.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Secure authentication flow',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Pallet.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Content
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Obx(() {
            final isAuthenticated =
                authController.homeController.mobileAuthenticated.value;
            final isExpired = authController.homeController.isAuthExpired.value;

            // If authenticated (regardless of expiration), show only authenticated widget
            if (isAuthenticated) {
              return _buildAuthenticatedWidget(authController, isExpired);
            }

            // If not authenticated, show all steps
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Saved Credentials Section
                _buildCredentialsSection(authController),
                const SizedBox(height: 32),

                // Step 1: Generate Payload
                _buildStepSection(
                  stepNumber: 1,
                  title: 'Generate Payload',
                  icon: Icons.qr_code_scanner_rounded,
                  color: const Color(0xFF3B82F6),
                  child: _buildPayloadSection(authController),
                ),
                const SizedBox(height: 32),

                // Step 2: Generate Signature
                _buildStepSection(
                  stepNumber: 2,
                  title: 'Generate Signature',
                  icon: Icons.fingerprint_rounded,
                  color: const Color(0xFF8B5CF6),
                  child: _buildSignatureSection(authController),
                ),
                const SizedBox(height: 32),

                // Step 3: Authenticate
                _buildStepSection(
                  stepNumber: 3,
                  title: 'Authenticate',
                  icon: Icons.verified_user_rounded,
                  color: const Color(0xFF10B981),
                  child: _buildAuthenticateSection(authController),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCredentialsSection(AuthController authController) {
    return Obx(() {
      final hasCredentials = authController.sdkCredentials.isNotEmpty;
      final selectedCred = authController.selectedSdkCredential.value;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Pallet.cardBackgroundSubtle,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Pallet.glassBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with title and Add button
            Row(
              children: [
                Icon(Icons.key_rounded, size: 20, color: Pallet.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Saved Credentials',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Pallet.textPrimary,
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Get.to(
                        () =>
                            SaveUpdateCredentials(title: 'SDK Authentication'),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Pallet.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Pallet.primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            size: 18,
                            color: Pallet.primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Add New',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Pallet.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!hasCredentials)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Pallet.cardBackgroundSubtle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Pallet.glassBorder, width: 1),
                ),
                child: Text(
                  'No credentials saved',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Pallet.textSecondary,
                  ),
                ),
              )
            else
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Pallet.glassBorder, width: 1),
                    ),
                    child: DropdownButtonHideUnderline(
                        child: DropdownButton<CredentialsModel>(
                        value: selectedCred,
                        isExpanded: true,
                        hint: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Select credentials',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Pallet.textSecondary,
                            ),
                          ),
                        ),
                        items: authController.sdkCredentials.map((cred) {
                          return DropdownMenuItem<CredentialsModel>(
                            value: cred,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    cred.title?.isNotEmpty == true
                                        ? cred.title!
                                        : cred.apiKey ?? 'No API Key',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Pallet.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (cred.title?.isNotEmpty == true)
                                    Text(
                                      cred.apiKey ?? 'No API Key',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Pallet.textSecondary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (CredentialsModel? selectedCred) {
                          if (selectedCred != null) {
                            authController.useSavedSdkCredentials(
                              selectedCred,
                              fromDropdown: true,
                            );
                          }
                        },
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        dropdownColor: Colors.white,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Pallet.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  if (selectedCred != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Get.to(
                                () => SaveUpdateCredentials(
                                  forUpdate: true,
                                  credentials: selectedCred,
                                  targetId: selectedCred.id,
                                  title:
                                      selectedCred.title ??
                                      'SDK Authentication',
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.edit_rounded,
                              size: 16,
                              color: Pallet.primaryColor,
                            ),
                            label: Text(
                              'Edit',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Pallet.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(
                                color: Pallet.primaryColor,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Get.dialog(
                                AlertDialog(
                                  title: Text(
                                    'Delete Credentials',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  content: Text(
                                    'Are you sure you want to delete these credentials?',
                                    style: GoogleFonts.inter(),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(),
                                      child: Text(
                                        'Cancel',
                                        style: GoogleFonts.inter(
                                          color: Pallet.textSecondary,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        authController.deleteCredentials(
                                          selectedCred.id!,
                                        );
                                        authController
                                                .selectedSdkCredential
                                                .value =
                                            null;
                                        Get.back();
                                      },
                                      child: Text(
                                        'Delete',
                                        style: GoogleFonts.inter(
                                          color: Pallet.errorColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.delete_rounded,
                              size: 16,
                              color: Pallet.errorColor,
                            ),
                            label: Text(
                              'Delete',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Pallet.errorColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(
                                color: Pallet.errorColor,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
          ],
        ),
      );
    });
  }

  Widget _buildStepSection({
    required int stepNumber,
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.15), color.withOpacity(0.08)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Step Number Badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$stepNumber',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Pallet.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Step Content
          Padding(padding: const EdgeInsets.all(20), child: child),
        ],
      ),
    );
  }

  Widget _buildPayloadSection(AuthController authController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppButton(
          text: 'Generate Payload',
          onTap: () => authController.generateSdkPayload(),
          backgroundColor: const Color(0xFF3B82F6),
          buttonIcon: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 20),
        Obx(() {
          if (!authController.sdkPayloadVisible.value) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Pallet.cardBackgroundSubtle,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Pallet.glassBorder, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: Pallet.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Click "Generate Payload" to create a unique payload',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Pallet.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF3B82F6).withOpacity(0.1),
                  const Color(0xFF3B82F6).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF3B82F6).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: const Color(0xFF3B82F6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Payload Generated',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          authController.sdkPayloadController.text,
                          style: GoogleFonts.firaCode(
                            fontSize: 12,
                            color: Pallet.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            authController.copyText(
                              authController.sdkPayloadController.text,
                            );
                            Utils.showToast('Payload copied to clipboard');
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.copy_rounded,
                              size: 18,
                              color: const Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSignatureSection(AuthController authController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description_rounded,
                  size: 18,
                  color: Pallet.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Payload',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Pallet.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CommonTextField(
              controller: authController.sdkSignaturePayloadController,
              hintText: 'Paste the generated payload here',
              maxLines: 3,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lock_rounded, size: 18, color: Pallet.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'Secret Key',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Pallet.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CommonTextField(
              controller: authController.sdkSignatureSecretController,
              hintText: 'Enter your secret key',
              isObscure: true,
            ),
          ],
        ),
        const SizedBox(height: 20),
        AppButton(
          text: 'Generate Signature',
          onTap: () => authController.generateSdkSignature(),
          backgroundColor: const Color(0xFF8B5CF6),
          buttonIcon: const Icon(
            Icons.fingerprint_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 20),
        Obx(() {
          if (!authController.sdkSignatureVisible.value) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Pallet.cardBackgroundSubtle,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Pallet.glassBorder, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: Pallet.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Enter payload and secret key, then generate signature',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Pallet.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF8B5CF6).withOpacity(0.1),
                  const Color(0xFF8B5CF6).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: const Color(0xFF8B5CF6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Signature Generated',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          authController.sdkSignatureController.text,
                          style: GoogleFonts.firaCode(
                            fontSize: 12,
                            color: Pallet.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            authController.copyText(
                              authController.sdkSignatureController.text,
                            );
                            Utils.showToast('Signature copied to clipboard');
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.copy_rounded,
                              size: 18,
                              color: const Color(0xFF8B5CF6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAuthenticateSection(AuthController authController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAuthField(
          label: 'API Key',
          icon: Icons.vpn_key_rounded,
          controller: authController.sdkAuthApiKeyController,
          hintText: 'Enter API Key',
        ),
        const SizedBox(height: 20),
        _buildAuthField(
          label: 'Payload',
          icon: Icons.description_rounded,
          controller: authController.sdkAuthPayloadController,
          hintText: 'Enter Payload',
          maxLines: 3,
        ),
        const SizedBox(height: 20),
        _buildAuthField(
          label: 'Signature',
          icon: Icons.fingerprint_rounded,
          controller: authController.sdkAuthSignatureController,
          hintText: 'Enter Signature',
          maxLines: 2,
        ),
        const SizedBox(height: 20),
        _buildAuthField(
          label: 'External ID (Optional)',
          icon: Icons.business_rounded,
          controller: authController.sdkAuthExternalIdController,
          hintText: 'Enter External ID',
        ),
        const SizedBox(height: 24),
        AppButton(
          text: 'Authenticate',
          onTap: () => authController.sdkAuthenticate(),
          backgroundColor: Pallet.primaryColor,
          buttonIcon: const Icon(
            Icons.verified_user_rounded,
            color: Colors.white,
            size: 20,
          ),
          showLoading: authController.sdkLoading.value,
        ),
      ],
    );
  }

  Widget _buildAuthField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Pallet.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Pallet.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CommonTextField(
          controller: controller,
          hintText: hintText,
          maxLines: maxLines,
        ),
      ],
    );
  }

  Widget _buildAuthenticatedWidget(
    AuthController authController,
    bool isExpired,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isExpired
                ? Pallet.warningColor.withOpacity(0.1)
                : Pallet.successColor.withOpacity(0.1),
            isExpired
                ? Pallet.warningColor.withOpacity(0.05)
                : Pallet.successColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpired
              ? Pallet.warningColor.withOpacity(0.3)
              : Pallet.successColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isExpired
                  ? Pallet.warningColor.withOpacity(0.15)
                  : Pallet.successColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isExpired ? Icons.warning_rounded : Icons.verified_user_rounded,
              size: 64,
              color: isExpired ? Pallet.warningColor : Pallet.successColor,
            ),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            isExpired ? 'Authentication Expired' : 'Authenticated Successfully',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Pallet.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          // Subtitle
          Text(
            isExpired
                ? 'Your authentication has expired. Please clear and re-authenticate to continue.'
                : 'You are successfully authenticated.',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Pallet.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Clear Authentication Button
          AppButton(
            text: 'Clear Authentication',
            onTap: () {
              authController.homeController.clearMobileAuth();
              Utils.showToast('Authentication cleared');
            },
            backgroundColor: isExpired
                ? Pallet.warningColor
                : Pallet.successColor,
            buttonIcon: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
