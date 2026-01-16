import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/auth/controller/auth_controller.dart';
import 'package:media_upload_sample_app/features/auth/models/credentials_model.dart';
import 'package:media_upload_sample_app/features/auth/views/save_update_credentials.dart';
import 'package:media_upload_sample_app/features/common/widgets/app_button.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_textfield.dart';

class InteractiveApiConsole extends StatelessWidget {
  const InteractiveApiConsole({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'API Endpoint',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Pallet.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Pallet.cardBackgroundSubtle,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Pallet.glassBorder, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Pallet.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'POST',
                    style: GoogleFonts.firaCode(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Pallet.successColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'https://sdk-mobile-api.truvideo.com/api/login',
                    style: GoogleFonts.firaCode(
                      fontSize: 12,
                      color: Pallet.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Saved Credentials Section
          Obx(() {
            final hasCredentials = authController.savedCredentials.isNotEmpty;
            final backOfficeCred = authController.backOfficeCredentials.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saved Credentials',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Pallet.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                if (!hasCredentials)
                  // No credentials - show Add Credentials button styled like dropdown
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Get.to(
                          () => SaveUpdateCredentials(
                            title: 'Back Office',
                            targetId: AuthController.BACK_OFFICE_ID,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Pallet.cardBackgroundSubtle,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Pallet.glassBorder,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_rounded,
                              size: 20,
                              color: Pallet.primaryColor,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Add Credentials',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Pallet.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  // Has credentials - show dropdown with edit/delete
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Pallet.cardBackgroundSubtle,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Pallet.glassBorder,
                            width: 1,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<CredentialsModel>(
                            value: backOfficeCred,
                            isExpanded: true,
                            hint: Text(
                              'Select credentials',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Pallet.textSecondary,
                              ),
                            ),
                            items: authController.savedCredentials.map((cred) {
                              return DropdownMenuItem<CredentialsModel>(
                                value: cred,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        cred.apiKey ?? 'No API Key',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Pallet.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (cred.externalId != null &&
                                          cred.externalId!.isNotEmpty)
                                        Text(
                                          'External ID: ${cred.externalId}',
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
                                authController.useSavedCredentials(
                                  selectedCred,
                                  forBackOffice: true,
                                  fromDropdown: true,
                                );
                              }
                            },
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            dropdownColor: Pallet.cardBackground,
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Pallet.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      if (backOfficeCred != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Get.to(
                                    () => SaveUpdateCredentials(
                                      forUpdate: true,
                                      credentials: backOfficeCred,
                                      targetId: backOfficeCred.id,
                                      title:
                                          backOfficeCred.title ?? 'Back Office',
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
                                    fontSize: 13,
                                    color: Pallet.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  side: BorderSide(
                                    color: Pallet.primaryColor,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
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
                                              backOfficeCred.id!,
                                            );
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
                                    fontSize: 13,
                                    color: Pallet.errorColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  side: BorderSide(
                                    color: Pallet.errorColor,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                const SizedBox(height: 24),
              ],
            );
          }),

          // Input Fields
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'API Key',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Pallet.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your unique identifier (like a username)',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Pallet.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CommonTextField(
            controller: authController.boApiKeyController,
            hintText: 'Enter your API Key',
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Secret Key',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Pallet.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your private password (keep it secret)',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Pallet.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CommonTextField(
            controller: authController.boSecretKeyController,
            hintText: 'Enter your Secret Key',
            isObscure: true,
          ),
          const SizedBox(height: 20),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'External ID',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Pallet.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your account number (Optional)',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Pallet.textSecondary,
                ),
              ),
            ],
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
                const SizedBox(height: 4),
                Text(
                  'The exact time this request was made',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Pallet.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Pallet.cardBackgroundSubtle,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Pallet.glassBorder, width: 1),
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
                const SizedBox(height: 4),
                Text(
                  'A digital fingerprint proving the request is from you',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Pallet.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Pallet.cardBackgroundSubtle,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Pallet.glassBorder, width: 1),
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

          // Try it / Clear Authentication Button
          Obx(
            () => AppButton(
              text: authController.homeController.boAuthenticated.value
                  ? 'Clear Authentication'
                  : 'Get Token',
              onTap: authController.homeController.boAuthenticated.value
                  ? () {
                      authController.homeController.clearBackOfficeAuth();
                      authController.resetDisplayData();
                    }
                  : () => authController.backOfficeAuthentication(),
              backgroundColor:
                  authController.homeController.boAuthenticated.value
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
