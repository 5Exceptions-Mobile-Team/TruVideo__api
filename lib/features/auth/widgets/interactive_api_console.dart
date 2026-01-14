import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/auth/controller/auth_controller.dart';
import 'package:media_upload_sample_app/features/auth/models/credentials_model.dart';
import 'package:media_upload_sample_app/features/common/widgets/app_button.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_textfield.dart';
import 'package:media_upload_sample_app/features/common/widgets/glass_container.dart';

class InteractiveApiConsole extends StatelessWidget {
  const InteractiveApiConsole({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'POST',
                  style: GoogleFonts.firaCode(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[400],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'ENDPOINT',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Pallet.textPrimary,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
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
            child: Obx(
              () => Text(
                '${authController.homeController.testingMode.value ? "https://sdk-mobile-api-rc.truvideo.com" : "https://sdk-mobile-api.truvideo.com"}/api/login',
                style: GoogleFonts.firaCode(
                  fontSize: 12,
                  color: Pallet.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Saved Credentials Dropdown
          Obx(() {
            if (authController.savedCredentials.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Use Saved Credentials',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Pallet.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Pallet.glassBorder,
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonFormField<CredentialsModel>(
                    value: null,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                    dropdownColor: Colors.white,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Pallet.textPrimary,
                    ),
                    hint: Text(
                      'Select saved credentials...',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Pallet.textSecondary,
                      ),
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Pallet.textSecondary,
                    ),
                    items: authController.savedCredentials.map((cred) {
                      return DropdownMenuItem<CredentialsModel>(
                        value: cred,
                        child: Text(
                          cred.title ?? cred.apiKey ?? 'Untitled',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Pallet.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (CredentialsModel? cred) {
                      if (cred != null) {
                        authController.useSavedCredentials(
                          cred,
                          forBackOffice: true,
                          fromDropdown: true,
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          }),
          
          // Input Fields
          Text(
            'API Key',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Pallet.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          CommonTextField(
            controller: authController.boApiKeyController,
            hintText: 'Enter your API Key',
          ),
          const SizedBox(height: 16),
          
          Text(
            'Secret Key',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Pallet.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          CommonTextField(
            controller: authController.boSecretKeyController,
            hintText: 'Enter your Secret Key',
            isObscure: true,
          ),
          const SizedBox(height: 16),
          
          Text(
            'External ID',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Pallet.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          CommonTextField(
            controller: authController.boExternalIdController,
            hintText: 'Enter your External ID',
          ),
          const SizedBox(height: 24),
          
          // Auto-generated fields (read-only)
          Obx(() {
            if (authController.generatedTimestamp.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Timestamp (Auto-generated)',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Pallet.textSecondary,
                  ),
                ),
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          authController.generatedTimestamp.value,
                          style: GoogleFonts.firaCode(
                            fontSize: 12,
                            color: Pallet.primaryColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => authController.copyText(
                          authController.generatedTimestamp.value,
                        ),
                        icon: Icon(
                          Icons.copy_rounded,
                          size: 18,
                          color: Pallet.textSecondary,
                        ),
                        tooltip: 'Copy timestamp',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Signature (Auto-generated)',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Pallet.textSecondary,
                  ),
                ),
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          authController.generatedSignature.value.length > 50
                              ? '${authController.generatedSignature.value.substring(0, 50)}...'
                              : authController.generatedSignature.value,
                          style: GoogleFonts.firaCode(
                            fontSize: 12,
                            color: Pallet.primaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => authController.copyText(
                          authController.generatedSignature.value,
                        ),
                        icon: Icon(
                          Icons.copy_rounded,
                          size: 18,
                          color: Pallet.textSecondary,
                        ),
                        tooltip: 'Copy signature',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          }),
          
          // Try it Button
          Obx(
            () => AppButton(
              text: authController.homeController.boAuthenticated.value
                  ? 'Authenticated ✓'
                  : 'Try it',
              onTap: authController.homeController.boAuthenticated.value
                  ? () {
                      authController.homeController.clearBackOfficeAuth();
                      authController.resetDisplayData();
                    }
                  : () => authController.backOfficeAuthentication(),
              backgroundColor: authController.homeController.boAuthenticated.value
                  ? Pallet.successColor
                  : Pallet.primaryColor,
              showLoading: authController.boLoading.value,
            ),
          ),
        ],
      ),
    );
  }
}
