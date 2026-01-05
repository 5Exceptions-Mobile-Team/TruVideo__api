import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/core/utils/utils.dart';
import 'package:media_upload_sample_app/features/media_upload/controller/media_upload_controller.dart';

class NumberOfPartsSelectorWidget extends StatelessWidget {
  final MediaUploadController controller;

  const NumberOfPartsSelectorWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isMultipartAllowed = controller.isMultipartAllowed();
      final maxParts = controller.getMaxAllowedParts();

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Number of Parts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Pallet.secondaryDarkColor,
                ),
              ),
              if (!isMultipartAllowed)
                Text(
                  'Files below 10MB must use 1 part',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                )
              else
                Text(
                  'Max $maxParts parts (Min 5MB each)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
            ],
          ),
          Row(
            spacing: 5,
            children: [
              Semantics(
                identifier: 'decrement_parts',
                label: 'decrement_parts',
                child: GestureDetector(
                  onTap: controller.decrementParts,
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: controller.numberOfParts.value > 1
                          ? Pallet.secondaryColor
                          : Colors.grey[400],
                    ),
                    child: Icon(Icons.remove, color: Colors.white),
                  ),
                ),
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Semantics(
                  identifier: 'number_of_parts',
                  label: 'number_of_parts',
                  child: Text(
                    '${controller.numberOfParts.value}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Pallet.secondaryDarkColor,
                    ),
                  ),
                ),
              ),
              Semantics(
                identifier: 'increment_parts',
                label: 'increment_parts',
                child: GestureDetector(
                  onTap: isMultipartAllowed
                      ? controller.incrementParts
                      : () {
                          Utils.showToast(
                            'Files below 10MB cannot be uploaded in parts',
                          );
                        },
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          (isMultipartAllowed &&
                              controller.numberOfParts.value < maxParts)
                          ? Pallet.secondaryColor
                          : Colors.grey[400],
                    ),
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}
