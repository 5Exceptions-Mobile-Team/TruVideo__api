import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/resourses/pallet.dart';
import '../controller/gallery_controller.dart';
import '../views/sdk_camera_screen.dart';

class AddMediaDialog extends StatelessWidget {
  const AddMediaDialog({super.key});

  @override
  Widget build(BuildContext context) {
    GalleryController galleryController = Get.find();
    return Dialog(
      backgroundColor: Pallet.secondaryBackground,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
        child: Column(
          spacing: 20,
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              identifier: 'sdk_camera',
              label: 'SDK Camera',
              child: GestureDetector(
                onTap: () {
                  Get.back();
                  Get.to(() => SdkCameraScreen());
                },
                child: Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Pallet.secondaryColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SDK Camera',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                ),
              ),
            ),
            Semantics(
              identifier: 'pick_file',
              label: 'Pick media from device',
              child: GestureDetector(
                onTap: () {
                  Get.back();
                  galleryController.pickFile();
                },
                child: Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Pallet.secondaryColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pick File',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
