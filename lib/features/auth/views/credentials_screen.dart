import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/auth/controller/auth_controller.dart';
import 'package:media_upload_sample_app/features/auth/models/credentials_model.dart';
import 'package:media_upload_sample_app/features/auth/views/save_update_credentials.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_app_bar.dart';
import 'package:media_upload_sample_app/features/common/widgets/gradient_background.dart';

class CredentialsScreen extends StatelessWidget {
  const CredentialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.find();
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CommonAppBar(
          title: 'Credentials',
          leading: Semantics(
            identifier: 'back_button',
            label: 'back_button',
            child: IconButton(
              onPressed: () => Get.back(),
              icon: Icon(Icons.arrow_back_rounded),
            ),
          ),
        ),
        body: Obx(
          () => SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    'Credentials',
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 24),
                  _buildCredentialCard(
                    context,
                    authController,
                    authController.backOfficeCredentials.value,
                    AuthController.BACK_OFFICE_ID,
                    'Back Office',
                    200,
                  ),
                  // const SizedBox(height: 30),
                  // if (authController.homeController.enableTruVideoSdk)
                  //   Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       _buildSectionHeader(
                  //         'Mobile Credentials',
                  //       ).animate().fadeIn(delay: 300.ms),
                  //       const SizedBox(height: 10),
                  //       _buildCredentialCard(
                  //         context,
                  //         authController,
                  //         authController.mobileCredentials.value,
                  //         AuthController.MOBILE_ID,
                  //         'Mobile',
                  //         400,
                  //       ),
                  //     ],
                  //   ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Pallet.textPrimary,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildCredentialCard(
    BuildContext context,
    AuthController authController,
    CredentialsModel? credentials,
    String targetId,
    String title,
    int delayMs,
  ) {
    if (credentials == null) {
      return Semantics(
        label: 'add_credentials',
        identifier: 'add_credentials',
        child: Material(
          color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.to(
            () => SaveUpdateCredentials(targetId: targetId, title: title),
          ),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Pallet.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Pallet.primaryColor.withOpacity(0.15),
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
            child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      color: Pallet.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add Credentials',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Pallet.primaryColor,
                  fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ).animate().fadeIn(delay: delayMs.ms).slideY(begin: 0.1);
    }

    return Semantics(
      label: 'credentials_card',
      identifier: 'credentials_card',
      child: Slidable(
        key: Key(credentials.id.toString()),
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (_) {
                Get.to(
                  () => SaveUpdateCredentials(
                    forUpdate: true,
                    credentials: credentials,
                    targetId: targetId,
                    title: title,
                  ),
                );
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ],
        ),
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (_) {
                authController.deleteCredentials(credentials.id!);
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Pallet.cardBackgroundAlt,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Pallet.secondaryColor.withOpacity(0.1),
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
          child: Semantics(
            identifier: 'credentials_button',
            label: 'credentials_button',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
              onTap: () => authController.useSavedCredentials(
                credentials,
                forBackOffice: title == 'Back Office',
              ),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                horizontal: 20,
                    vertical: 16,
              ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                credentials.apiKey ?? '',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Pallet.textPrimary,
                              ),
              ),
                            const SizedBox(height: 4),
                            Text(
                credentials.secret ?? '',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Pallet.textSecondary,
                              ),
                            ),
                          ],
                        ),
              ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Pallet.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: delayMs.ms).slideY(begin: 0.1);
  }
}
