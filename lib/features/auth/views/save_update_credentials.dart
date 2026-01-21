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
  late TextEditingController titleController;
  late TextEditingController apiKeyController;
  late TextEditingController secretKeyController;
  late TextEditingController externalIdController;

  late AuthController authController;

  // Determine credential type based on title or targetId
  String? get credentialType {
    if (widget.forUpdate && widget.credentials != null) {
      // For updates, use existing credentialType or determine from title
      return widget.credentials!.credentialType ??
          (widget.credentials!.title?.toLowerCase().contains('sdk') == true ||
                  widget.targetId == AuthController.MOBILE_ID
              ? 'SDK'
              : 'API');
    } else {
      // For new credentials, determine from title or targetId
      if (widget.title?.toLowerCase().contains('sdk') == true ||
          widget.targetId == AuthController.MOBILE_ID) {
        return 'SDK';
      } else if (widget.title?.toLowerCase().contains('back office') == true ||
          widget.title?.toLowerCase().contains('api') == true ||
          widget.targetId == AuthController.BACK_OFFICE_ID) {
        return 'API';
      }
      // Default to API if unclear
      return 'API';
    }
  }

  @override
  void initState() {
    authController = Get.put(AuthController());
    titleController = TextEditingController();
    apiKeyController = TextEditingController();
    secretKeyController = TextEditingController();
    externalIdController = TextEditingController();

    if (widget.forUpdate) {
      titleController.text = widget.credentials!.title ?? '';
      apiKeyController.text = widget.credentials!.apiKey!;
      secretKeyController.text = widget.credentials!.secret!;
      externalIdController.text = widget.credentials!.externalId ?? '';
    }
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
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
          title: widget.forUpdate ? 'Update Credentials' : 'Save Credentials',
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
              text: widget.forUpdate ? 'Update' : 'Save',
              onTap: () => authController.saveUpdateCredentials(
                widget.forUpdate,
                apiKeyController.text.trim(),
                secretKeyController.text.trim(),
                externalIdController.text.trim(),
                id: widget.forUpdate ? widget.credentials?.id : null,
                title: titleController.text.trim().isEmpty
                    ? widget.title
                    : titleController.text.trim(),
                credentialType: credentialType,
              ),
              backgroundColor: Pallet.primaryDarkColor,
            ),
          ),
          SizedBox(height: 5),
        ],
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Title',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Semantics(
                    identifier: 'title_field',
                    label: 'Title field',
                    child: CommonTextField(
                      controller: titleController,
                      hintText: 'Title or Environment',
                    ),
                  ),
                  const SizedBox(height: 20),
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
