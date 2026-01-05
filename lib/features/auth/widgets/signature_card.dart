import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/auth/controller/auth_controller.dart';
import 'package:media_upload_sample_app/features/common/widgets/app_button.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_textfield.dart';
import 'package:media_upload_sample_app/features/common/widgets/glass_container.dart';

class SignatureCard extends StatelessWidget {
  final String title;
  const SignatureCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.find();
    return Obx(
      () => GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Semantics(
              identifier: 'signature_payload_textfield',
              label: 'signature_payload_textfield',
              child: CommonTextField(
                controller: authController.signaturePayloadController,
                hintText: 'Payload',
              ),
            ),
            const SizedBox(height: 20),
            Semantics(
              identifier: 'signature_secret_key',
              label: 'signature_secret_key',
              child: CommonTextField(
                controller: authController.signatureSecretController,
                hintText: 'Secret Key',
              ),
            ),
            const SizedBox(height: 20),
            Visibility(
              visible: authController.signatureVisible.value,
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Semantics(
                    identifier: 'signature_field',
                    label: 'signature_field',
                    child: CommonTextField(
                      controller: authController.signatureController,
                      hintText: 'Signature',
                      maxLines: 3,
                      suffixIcon: const SizedBox(width: 5),
                    ),
                  ),
                  Semantics(
                    identifier: 'copy_signature',
                    label: 'copy_signature',
                    child: IconButton(
                      onPressed: () => authController.copyText(
                        authController.signatureController.text,
                      ),
                      icon: Icon(Icons.copy, color: Pallet.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
            if (authController.signatureVisible.value)
              const SizedBox(height: 20),
            Semantics(
              identifier: 'generate_signature',
              label: 'generate_signature',
              child: AppButton(
                text: 'Generate',
                onTap: () => authController.generateSignature(),
                backgroundColor: Pallet.secondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
