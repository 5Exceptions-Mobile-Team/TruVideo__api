import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/auth/controller/auth_controller.dart';
import 'package:media_upload_sample_app/features/common/widgets/app_button.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_textfield.dart';
import 'package:media_upload_sample_app/features/common/widgets/glass_container.dart';

class PayloadCard extends StatefulWidget {
  final String title;
  const PayloadCard({super.key, required this.title});

  @override
  State<PayloadCard> createState() => _PayloadCardState();
}

class _PayloadCardState extends State<PayloadCard> {
  late AuthController authController;

  @override
  void initState() {
    authController = Get.find();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 15),
            Visibility(
              visible: authController.payloadVisible.value,
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Semantics(
                    identifier: 'payload_textfield',
                    label: 'payload_textfield',
                    child: CommonTextField(
                      controller: authController.payloadController,
                      hintText: 'Generate Payload',
                      maxLines: 4,
                      suffixIcon: const SizedBox(width: 5),
                    ),
                  ),
                  Semantics(
                    identifier: 'copy_payload',
                    label: 'copy_payload',
                    child: IconButton(
                      onPressed: () => authController.copyText(
                        authController.payloadController.text,
                      ),
                      icon: Icon(Icons.copy, color: Pallet.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
            if (authController.payloadVisible.value) const SizedBox(height: 15),
            Semantics(
              identifier: 'generate_payload',
              label: 'generate_payload',
              child: AppButton(
                text: 'Generate',
                onTap: () => authController.generatePayload(),
                backgroundColor: Pallet.secondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
