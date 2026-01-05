import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/auth/controller/auth_controller.dart';
import 'package:media_upload_sample_app/features/auth/models/credentials_model.dart';
import 'package:media_upload_sample_app/features/common/widgets/app_button.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_app_bar.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_textfield.dart';
import 'package:media_upload_sample_app/features/common/widgets/gradient_background.dart';

class SaveUpdateCredentials extends StatefulWidget {
  final bool forUpdate;
  final CredentialsModel? credentials;
  final String? targetId;
  final String? title;

  const SaveUpdateCredentials({
    super.key,
    this.forUpdate = false,
    this.credentials,
    this.targetId,
    this.title,
  });

  @override
  State<SaveUpdateCredentials> createState() => _SaveUpdateCredentialsState();
}

class _SaveUpdateCredentialsState extends State<SaveUpdateCredentials> {
  late TextEditingController apiKeyController;
  late TextEditingController secretKeyController;
  late TextEditingController externalIdController;

  late AuthController authController;

  @override
  void initState() {
    authController = Get.put(AuthController());
    apiKeyController = TextEditingController();
    secretKeyController = TextEditingController();
    externalIdController = TextEditingController();

    if (widget.forUpdate) {
      apiKeyController.text = widget.credentials!.apiKey!;
      secretKeyController.text = widget.credentials!.secret!;
      externalIdController.text = widget.credentials!.externalId!;
    }
    super.initState();
  }

  @override
  void dispose() {
    apiKeyController.dispose();
    secretKeyController.dispose();
    externalIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CommonAppBar(
          title: widget.forUpdate
              ? 'Update ${widget.title ?? "Credentials"}'
              : 'Create ${widget.title ?? "Credentials"}',
          leading: Semantics(
            identifier: 'back_button',
            label: 'back_button',
            child: IconButton(
              onPressed: () => Get.back(),
              icon: Icon(Icons.arrow_back_rounded),
            ),
          ),
        ),
        persistentFooterButtons: [
          Semantics(
            identifier: 'save_credentials',
            label: 'Save or update credentials',
            child: AppButton(
              text: widget.forUpdate ? 'Update' : 'Create',
              onTap: () => authController.saveUpdateCredentials(
                widget.forUpdate,
                apiKeyController.text.trim(),
                secretKeyController.text.trim(),
                externalIdController.text.trim(),
                id: widget.forUpdate ? widget.credentials?.id : widget.targetId,
                title: widget.title,
              ),
              backgroundColor: Pallet.primaryDarkColor,
            ),
          ),
        ],
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Api Key',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Semantics(
                    identifier: 'api_key_field',
                    label: 'API key field',
                    child: CommonTextField(
                      controller: apiKeyController,
                      hintText: 'Api Key',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Secret Key',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Semantics(
                    identifier: 'secret_key_field',
                    label: 'Secret key field',
                    child: CommonTextField(
                      controller: secretKeyController,
                      hintText: 'Secret Key',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'External Id',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Semantics(
                    identifier: 'external_id_field',
                    label: 'External id field',
                    child: CommonTextField(
                      controller: externalIdController,
                      hintText: 'External Id',
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
