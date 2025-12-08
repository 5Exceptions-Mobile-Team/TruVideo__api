import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/auth/controller/auth_controller.dart';
import 'package:media_upload_sample_app/features/common/widgets/app_button.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_textfield.dart';

class SignatureCard extends StatelessWidget {
  final String title;
  const SignatureCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.find();
    return Obx(
      () => Card(
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
                identifier: 'signature_payload_textfield',
                label: 'Payload field for signature card',
                child: CommonTextField(
                  controller: authController.signaturePayloadController,
                  hintText: 'Payload',
                ),
              ),
              Semantics(
                identifier: 'secret_key',
                label: 'Secret key textfield',
                child: CommonTextField(
                  controller: authController.signatureSecretController,
                  hintText: 'Secret Key',
                ),
              ),
              Visibility(
                visible: authController.signatureVisible.value,
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Semantics(
                      identifier: 'signature_field',
                      label: 'Generate signature field',
                      child: CommonTextField(
                        controller: authController.signatureController,
                        hintText: 'Signature',
                        maxLines: 3,
                        suffixIcon: SizedBox(width: 5),
                      ),
                    ),
                    Semantics(
                      identifier: 'copy_signature',
                      label: 'Copy Signature',
                      child: IconButton(
                        onPressed: () => authController.copyText(
                          authController.signatureController.text,
                        ),
                        icon: Icon(Icons.copy, color: Pallet.tertiaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              Semantics(
                identifier: 'generate_signature',
                label: 'Generate signature button',
                child: AppButton(
                  text: 'Generate',
                  onTap: () => authController.generateSignature(),
                  backgroundColor: Pallet.secondaryDarkColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
