import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/auth/controller/auth_controller.dart';
import 'package:media_upload_sample_app/features/auth/models/credentials_model.dart';
import 'package:media_upload_sample_app/features/auth/views/save_update_credentials.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_app_bar.dart';

class CredentialsScreen extends StatelessWidget {
  const CredentialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.find();
    return Scaffold(
      appBar: CommonAppBar(title: 'Credentials'),
      body: Obx(
        () => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Back Office Credentials'),
                const SizedBox(height: 10),
                _buildCredentialCard(
                  context,
                  authController,
                  authController.backOfficeCredentials.value,
                  AuthController.BACK_OFFICE_ID,
                  'Back Office',
                ),
                const SizedBox(height: 30),
                _buildSectionHeader('Mobile Credentials'),
                const SizedBox(height: 10),
                _buildCredentialCard(
                  context,
                  authController,
                  authController.mobileCredentials.value,
                  AuthController.MOBILE_ID,
                  'Mobile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCredentialCard(
    BuildContext context,
    AuthController authController,
    CredentialsModel? credentials,
    String targetId,
    String title,
  ) {
    if (credentials == null) {
      return Semantics(
        label: 'add_credentials',
        identifier: 'add_credentials',
        child: InkWell(
          onTap: () => Get.to(
            () => SaveUpdateCredentials(targetId: targetId, title: title),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Pallet.secondaryBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
            ),
            child: const Center(
              child: Text(
                '+ Add Credentials',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      );
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
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Pallet.secondaryBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Semantics(
            identifier: 'credentials_button',
            label: 'credentials_button',
            child: ListTile(
              onTap: () => authController.useSavedCredentials(
                credentials,
                forBackOffice: title == 'Back Office',
              ),
              title: Text(
                credentials.apiKey ?? '',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(credentials.secret ?? ''),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
        ),
      ),
    );
  }
}
