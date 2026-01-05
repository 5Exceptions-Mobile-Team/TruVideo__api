import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/auth/controller/auth_controller.dart';
import 'package:media_upload_sample_app/features/common/widgets/app_button.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_textfield.dart';
import 'package:media_upload_sample_app/features/common/widgets/glass_container.dart';

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
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Semantics(
            identifier: forBackOffice
                ? 'back_office_api_key_field'
                : 'mobile_api_key_field',
            label: forBackOffice
                ? 'back_office_api_key_field'
                : 'mobile_api_key_field',
            child: CommonTextField(
              controller: forBackOffice
                  ? authController.boApiKeyController
                  : authController.authApiKeyController,
              hintText: 'API Key',
            ),
          ),
          if (!forBackOffice) ...[
            const SizedBox(height: 16),
            Semantics(
              identifier: 'mobile_payload_field',
              label: 'mobile_payload_field',
              child: CommonTextField(
                controller: authController.authPayloadController,
                hintText: 'Payload',
              ),
            ),
          ],
          if (!forBackOffice) ...[
            const SizedBox(height: 16),
            Semantics(
              identifier: 'mobile_signature_field',
              label: 'mobile_signature_field',
              child: CommonTextField(
                controller: authController.authSignatureController,
                hintText: 'Signature',
              ),
            ),
          ],
          if (forBackOffice) ...[
            const SizedBox(height: 16),
            Semantics(
              identifier: 'back_office_secret_key',
              label: 'back_office_secret_key',
              child: CommonTextField(
                controller: authController.boSecretKeyController,
                hintText: 'Secret Key',
              ),
            ),
          ],
          const SizedBox(height: 16),
          Semantics(
            identifier: forBackOffice
                ? 'back_office_external_id_field'
                : 'mobile_external_id_field',
            label: forBackOffice
                ? 'back_office_external_id_field'
                : 'mobile_external_id_field',
            child: CommonTextField(
              controller: forBackOffice
                  ? authController.boExternalIdController
                  : authController.authExternalIdController,
              hintText: 'External Id',
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => Semantics(
              identifier: forBackOffice
                  ? 'back_office_authenticate_button'
                  : 'mobile_authenticate_button',
              label: forBackOffice
                  ? 'back_office_authenticate_button'
                  : 'mobile_authenticate_button',
              child: AppButton(
                onTap: () => forBackOffice
                    ? authController.backOfficeAuthentication()
                    : authController.authenticate(),
                text: forBackOffice
                    ? authController.homeController.boAuthenticated.value
                          ? 'Authenticated'
                          : 'Authenticate'
                    : 'Authenticate',
                backgroundColor: Pallet.primaryColor,
                showLoading: forBackOffice
                    ? authController.boLoading.value
                    : authController.showLoading.value,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
