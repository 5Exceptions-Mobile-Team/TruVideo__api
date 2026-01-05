import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/media_upload/controller/media_upload_controller.dart';

class CheckboxesRowWidget extends StatelessWidget {
  final MediaUploadController controller;

  const CheckboxesRowWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: Semantics(
              identifier: 'add_to_library',
              label: 'add_to_library',
              child: CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: controller.isLibrary.value,
                onChanged: (value) =>
                    controller.isLibrary.value = value ?? true,
                title: Text(
                  'Add to library',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                activeColor: Pallet.secondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Semantics(
              identifier: 'include_in_report',
              label: 'include_in_report',
              child: CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: controller.includeInReport.value,
                onChanged: (value) =>
                    controller.includeInReport.value = value ?? true,
                title: Text(
                  'Include in report',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                activeColor: Pallet.secondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
