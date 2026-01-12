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
import 'package:media_upload_sample_app/features/common/widgets/glass_container.dart';
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    'Credentials',
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 10),
                  _buildCredentialCard(
                    context,
                    authController,
                    authController.backOfficeCredentials.value,
                    AuthController.BACK_OFFICE_ID,
                    'Back Office',
                    200,
                  ),
                  const SizedBox(height: 30),
                  if (authController.homeController.enableTruVideoSdk)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          'Mobile Credentials',
                        ).animate().fadeIn(delay: 300.ms),
                        const SizedBox(height: 10),
                        _buildCredentialCard(
                          context,
                          authController,
                          authController.mobileCredentials.value,
                          AuthController.MOBILE_ID,
                          'Mobile',
                          400,
                        ),
                      ],
                    ),
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
      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
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
        child: InkWell(
          onTap: () => Get.to(
            () => SaveUpdateCredentials(targetId: targetId, title: title),
          ),
          child: GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                '+ Add Credentials',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Pallet.primaryColor,
                  fontWeight: FontWeight.w600,
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
        child: GlassContainer(
          padding: EdgeInsets.zero,
          child: Semantics(
            identifier: 'credentials_button',
            label: 'credentials_button',
            child: ListTile(
              onTap: () => authController.useSavedCredentials(
                credentials,
                forBackOffice: title == 'Back Office',
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              title: Text(
                credentials.apiKey ?? '',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                credentials.secret ?? '',
                style: GoogleFonts.inter(),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: delayMs.ms).slideY(begin: 0.1);
  }
}
