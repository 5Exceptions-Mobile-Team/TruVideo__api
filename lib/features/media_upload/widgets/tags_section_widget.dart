import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_textfield.dart';
import 'package:media_upload_sample_app/features/media_upload/controller/media_upload_controller.dart';

class TagsSectionWidget extends StatelessWidget {
  final MediaUploadController controller;

  const TagsSectionWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tags',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Pallet.secondaryDarkColor,
              ),
            ),
            Row(
              spacing: 10,
              children: [
                Semantics(
                  identifier: 'add_tag_row',
                  label: 'add_tag_row',
                  child: GestureDetector(
                    onTap: controller.addTagRow,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Pallet.secondaryColor,
                      ),
                      child: Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ),
                Semantics(
                  identifier: 'remove_tag',
                  label: 'remove_tag',
                  child: GestureDetector(
                    onTap: controller.removeLastTagRow,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Pallet.secondaryColor,
                      ),
                      child: Icon(Icons.remove, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Obx(
          () => Column(
            children: [
              for (int i = 0; i < controller.tagControllers.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: Semantics(
                          identifier: 'tag_key',
                          label: 'tag_key',
                          child: CommonTextField(
                            controller: controller.tagControllers[i]['key']!,
                            hintText: 'Key',
                          ),
                        ),
                      ),
                      Expanded(
                        child: Semantics(
                          identifier: 'tag_value',
                          label: 'tag_value',
                          child: CommonTextField(
                            controller: controller.tagControllers[i]['value']!,
                            hintText: 'Value',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
