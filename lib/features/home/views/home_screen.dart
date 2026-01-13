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
        appBar: const CommonAppBar(
          title: 'Media Upload Sample App',
          centerTitle: true,
        ),
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
                const SizedBox(height: 24),
                _buildAppInfoContainer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfoContainer() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Getting Started',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Pallet.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFlowStep(
            step: 1,
            icon: Icons.lock_rounded,
            title: 'Complete Authentication',
            description:
                'Start by authenticating using your API credentials. Navigate to the Authentication section and enter your API Key and Secret Key to get your access token.',
            color: Colors.blue,
          ),
          _buildFlowConnector(),
          _buildFlowStep(
            step: 2,
            icon: Icons.photo_library_rounded,
            title: 'Pick Media from Device',
            description:
                'Access the Gallery to browse and select media files (videos and images) from your device that you want to upload.',
            color: Colors.blue,
          ),
          _buildFlowConnector(),
          _buildFlowStep(
            step: 3,
            icon: Icons.cloud_upload_rounded,
            title: 'Upload',
            description:
                'Upload your selected media files using Upload API\'s. The API\'s supports secure, multipart file uploads for large files.',
            color: Colors.blue,
            isLast: true,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.api_rounded, color: Colors.blue, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'API Version: V3',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Pallet.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'This app uses TruVideo Upload V3 API\'s for media uploads.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Pallet.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildFlowStep({
    required int step,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Center(child: Icon(icon, color: color, size: 16)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Step $step',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Pallet.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Pallet.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlowConnector() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 4, bottom: 4),
      child: Container(
        width: 2,
        height: 12,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Pallet.glassBorder,
              Pallet.glassBorder.withValues(alpha: 0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(1),
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
