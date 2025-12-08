import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/auth/views/auth_screen.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_app_bar.dart';
import 'package:media_upload_sample_app/features/common/widgets/error_widget.dart';
import 'package:media_upload_sample_app/features/gallery/views/gallery_screen.dart';
import 'package:media_upload_sample_app/features/home/controller/home_controller.dart';
import 'package:media_upload_sample_app/features/home/widgets/feature_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeController homeController;

  @override
  void initState() {
    homeController = Get.find();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Media Upload Sample App'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 5,
                  children: [
                    Expanded(
                      child: Semantics(
                        identifier: 'core',
                        label: 'Core Module',
                        child: FeatureCard(
                          onTap: () => Get.to(
                            () => AuthScreen(
                              isAuthenticated:
                                  (homeController.mobileAuthenticated.value &&
                                  !homeController
                                      .isAuthExpired
                                      .value), // Authenticated and auth is not expired
                            ),
                          ),
                          icon: Icon(
                            Icons.lock,
                            color: Pallet.secondaryColor,
                            size: context.width * 0.25,
                          ),
                          title: 'Core',
                        ),
                      ),
                    ),
                    Expanded(
                      child: Semantics(
                        identifier: 'gallery_screen',
                        label: 'Gallery Button',
                        child: FeatureCard(
                          onTap: () {
                            if (homeController.mobileAuthenticated.value &&
                                homeController.isAuthExpired.value == false) {
                              Get.to(() => GalleryScreen(onSelect: (_) {}));
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => ErrorDialog(),
                              );
                            }
                          },
                          icon: Icon(
                            Icons.camera_alt,
                            color: Pallet.secondaryColor,
                            size: context.width * 0.25,
                          ),
                          title: 'Gallery',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  ' Authentication',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Obx(
                  () => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Is Authenticated'),
                              Semantics(
                                identifier: 'auth_status',
                                label: 'Is Authenticated',
                                child: Text(
                                  homeController.mobileAuthenticated.value
                                      .toString(),
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Is Authentication Expired '),
                              Semantics(
                                identifier: 'auth_expired',
                                label: 'Is auth expired',
                                child: Text(
                                  homeController.isAuthExpired.value.toString(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
