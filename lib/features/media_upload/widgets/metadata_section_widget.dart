import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_textfield.dart';
import 'package:media_upload_sample_app/features/media_upload/controller/media_upload_controller.dart';

class MetadataSectionWidget extends StatelessWidget {
  final MediaUploadController controller;

  const MetadataSectionWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Metadata',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Pallet.textMain,
              ),
            ),
            Row(
              children: [
                _buildActionButton(
                  icon: Icons.add,
                  onTap: controller.addMetadataRow,
                ),
                const SizedBox(width: 10),
                _buildActionButton(
                  icon: Icons.remove,
                  onTap: controller.removeLastMetadataRow,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(
          () => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.metadataControllers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return Row(
                children: [
                  Expanded(
                    child: Semantics(
                      identifier: 'metadata_key',
                      label: 'metadata_key',
                      child: CommonTextField(
                        valueKey: Key('metadata_key'),
                        controller:
                            controller.metadataControllers[index]['key']!,
                        hintText: 'Key',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Semantics(
                      identifier: 'metadata_value',
                      label: 'metadata_value',
                      child: CommonTextField(
                        valueKey: Key('metadata_value'),
                        controller:
                            controller.metadataControllers[index]['value']!,
                        hintText: 'Value',
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Pallet.secondaryColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: Pallet.whiteColor),
      ),
    );
  }
}
