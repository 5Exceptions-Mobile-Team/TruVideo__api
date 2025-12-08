import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/auth/controller/auth_controller.dart';
import 'package:media_upload_sample_app/features/common/widgets/app_button.dart';

class AuthenticatedWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onClear;
  const AuthenticatedWidget({
    super.key,
    this.title = 'Authenticated Successfully',
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.find();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          spacing: 20,
          children: [
            Icon(
              Icons.verified_user_rounded,
              size: 90,
              color: Pallet.secondaryDarkColor,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Semantics(
              identifier: 'core_clear_auth',
              label: 'Clear Authentication',
              child: AppButton(
                onTap: () {
                  if (onClear != null) {
                    onClear!();
                  } else {
                    authController.clearAuth();
                  }
                },
                text: 'Clear Authentication',
                backgroundColor: Pallet.secondaryDarkColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
