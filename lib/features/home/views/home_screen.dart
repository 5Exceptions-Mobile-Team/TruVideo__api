import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/auth/views/auth_screen.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_app_bar.dart';
import 'package:media_upload_sample_app/features/common/widgets/error_widget.dart';
import 'package:media_upload_sample_app/features/common/widgets/glass_container.dart';
import 'package:media_upload_sample_app/features/common/widgets/gradient_background.dart';
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
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CommonAppBar(title: 'Media Upload Sample App'),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        identifier: 'auth',
                        label: 'Auth Module',
                        child: FeatureCard(
                          onTap: () => Get.to(
                            () => AuthScreen(
                              isAuthenticated:
                                  (homeController.mobileAuthenticated.value &&
                                  !homeController.isAuthExpired.value),
                            ),
                          ),
                          icon: Icon(
                            Icons.lock_outline_rounded,
                            color: Pallet.primaryColor,
                            size: 48,
                          ),
                          title: 'Authentication',
                        ),
                      ),
                    ).animate().fadeIn(delay: 100.ms).slideX(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Semantics(
                        identifier: 'gallery_screen',
                        label: 'Gallery Button',
                        child: FeatureCard(
                          onTap: () {
                            if (homeController.isFullyAuthenticated.value) {
                              Get.to(() => GalleryScreen(onSelect: (_) {}));
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => const ErrorDialog(),
                              );
                            }
                          },
                          icon: Icon(
                            Icons.camera_alt_outlined,
                            color: Pallet.secondaryColor,
                            size: 48,
                          ),
                          title: 'Gallery',
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideX(),
                  ],
                ),
                const SizedBox(height: 24),
                GlassContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Testing/QA Mode',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Semantics(
                        identifier: 'testing_mode',
                        label: 'testing_mode',
                        child: Obx(
                          () => Switch(
                            value: homeController.testingMode.value,
                            onChanged: (value) {
                              homeController.testingMode.value = value;
                              homeController.storage.write(
                                HomeController.TESTING_MODE_KEY,
                                value,
                              );
                            },
                            activeThumbColor: Pallet.primaryColor,
                            inactiveThumbColor: Pallet.greyColor,
                            activeTrackColor: Pallet.primaryColor.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                const SizedBox(height: 24),
                Text(
                  'Authentication Status',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 12),
                GlassContainer(
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusRow(
                          'Is Authenticated',
                          homeController.isFullyAuthenticated.value.toString(),
                          'auth_status',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(height: 1),
                        ),
                        _buildStatusRow(
                          'Is Authentication Expired',
                          homeController.boExpired.value.toString(),
                          'auth_expired',
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, String identifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(color: Pallet.textSecondary, fontSize: 14),
        ),
        Semantics(
          identifier: identifier,
          label: label,
          child: Text(
            value,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
