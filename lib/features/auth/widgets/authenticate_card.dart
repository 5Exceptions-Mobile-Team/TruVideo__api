import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/auth/controller/auth_controller.dart';
import 'package:media_upload_sample_app/features/common/widgets/app_button.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_textfield.dart';

class AuthenticateCard extends StatelessWidget {
  final String title;
  final bool forBackOffice;
  const AuthenticateCard({
    super.key,
    required this.title,
    this.forBackOffice = false,
  });

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.find();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Semantics(
              identifier: 'api_key_field',
              label: 'API key textfield',
              child: CommonTextField(
                controller: forBackOffice
                    ? authController.boApiKeyController
                    : authController.authApiKeyController,
                hintText: 'API Key',
              ),
            ),
            if (!forBackOffice)
              Semantics(
                identifier: 'payload_field',
                label: 'Payload textfield',
                child: CommonTextField(
                  controller: authController.authPayloadController,
                  hintText: 'Payload',
                ),
              ),
            if (!forBackOffice)
              Semantics(
                identifier: 'signature_field',
                label: 'Signature textfield',
                child: CommonTextField(
                  controller: authController.authSignatureController,
                  hintText: 'Signature',
                ),
              ),
            if (forBackOffice)
              Semantics(
                identifier: 'secret_key',
                label: 'Secret key textfield',
                child: CommonTextField(
                  controller: authController.boSecretKeyController,
                  hintText: 'Secret Key',
                ),
              ),
            Semantics(
              identifier: 'external_id_field',
              label: 'External id textfield',
              child: CommonTextField(
                controller: forBackOffice
                    ? authController.boExternalIdController
                    : authController.authExternalIdController,
                hintText: 'External Id',
              ),
            ),
            Obx(
              () => Semantics(
                identifier: 'authenticate_button',
                label: 'Authenticate Button',
                child: AppButton(
                  onTap: () => forBackOffice
                      ? authController.backOfficeAuthentication()
                      : authController.authenticate(),
                  text: forBackOffice
                      ? authController.homeController.boAuthenticated.value
                            ? 'Authenticated'
                            : 'Authenticate'
                      : 'Authenticate',
                  backgroundColor: Pallet.secondaryDarkColor,
                  showLoading: forBackOffice
                      ? authController.boLoading.value
                      : authController.showLoading.value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
