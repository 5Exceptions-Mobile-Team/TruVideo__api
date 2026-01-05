import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/auth/controller/auth_controller.dart';
import 'package:media_upload_sample_app/features/common/widgets/app_button.dart';
import 'package:media_upload_sample_app/features/common/widgets/glass_container.dart';

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
    return GlassContainer(
      child: Column(
        children: [
          Icon(
            Icons.verified_user_rounded,
            size: 90,
            color: Pallet.primaryColor,
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Semantics(
            identifier: 'clear_authentication',
            label: 'clear_authentication',
            child: AppButton(
              onTap: () {
                if (onClear != null) {
                  onClear!();
                } else {
                  authController.clearAuth();
                }
              },
              text: 'Clear Authentication',
              backgroundColor: Pallet.errorColor,
            ),
          ),
        ],
      ),
    );
  }
}
