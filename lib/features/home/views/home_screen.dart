import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_upload_sample_app/features/auth/views/auth_screen.dart';
import 'package:media_upload_sample_app/features/common/widgets/authentication_required_dialog.dart';
import 'package:media_upload_sample_app/features/gallery/views/gallery_screen.dart';
import 'package:media_upload_sample_app/features/home/controller/home_controller.dart';
import 'package:media_upload_sample_app/features/home/widgets/demo_video_player.dart';

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
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Hero Banner
                  _buildHeroBanner(isDesktop),

                  // Main Content
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 32 : 20,
                      vertical: isDesktop ? 32 : 24,
                    ),
                    child: isDesktop
                        ? _buildDesktopLayout()
                        : _buildMobileLayout(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Side - Getting Started / Info (40%)
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _buildGettingStartedSection(),
              const SizedBox(height: 20),
              _buildApiVersionBadge(),
            ],
          ),
        ),
        const SizedBox(width: 28),
        // Right Side - Cards and Status (60%)
        Expanded(
          flex: 6,
          child: Column(
            children: [
              _buildFeatureCard(isAuth: true),
              const SizedBox(height: 20),
              _buildFeatureCard(isAuth: false),
              const SizedBox(height: 20),
              _buildAuthStatusCard(),
              const SizedBox(height: 20),
              _buildWhyUseTruvideo(),
              const SizedBox(height: 20),
              const DemoVideoPlayer(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildFeatureCard(isAuth: true),
        const SizedBox(height: 16),
        _buildFeatureCard(isAuth: false),
        const SizedBox(height: 20),
        _buildAuthStatusCard(),
        const SizedBox(height: 20),
        _buildWhyUseTruvideo(),
        const SizedBox(height: 24),
        _buildGettingStartedSection(),
        const SizedBox(height: 24),
        const DemoVideoPlayer(),
        const SizedBox(height: 24),
        _buildApiVersionBadge(),
      ],
    );
  }

  Widget _buildHeroBanner(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : 24,
        vertical: isDesktop ? 32 : 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2196F3), Color(0xFF1976D2), Color(0xFF1565C0)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Video Platform API',
            style: GoogleFonts.inter(
              fontSize: isDesktop ? 32 : 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your media files securely using our Video Platform API.',
            style: GoogleFonts.inter(
              fontSize: isDesktop ? 15 : 13,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthStatusCard() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Authentication Status',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Current authentication status',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: homeController.isFullyAuthenticated.value
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: homeController.isFullyAuthenticated.value
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF9800),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    homeController.isFullyAuthenticated.value
                        ? Icons.check_circle_rounded
                        : Icons.pending_rounded,
                    size: 18,
                    color: homeController.isFullyAuthenticated.value
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFF9800),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    homeController.isFullyAuthenticated.value
                        ? 'Authenticated'
                        : 'Not Authenticated',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: homeController.isFullyAuthenticated.value
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFE65100),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhyUseTruvideo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            size: 22,
            color: Color(0xFFF9A825),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why Use Video Platform APIs?',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Secure cloud storage, fast uploads (even for large files), automatic file processing, and easy integration with your existing systems. Perfect for businesses that deal with lots of media files.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiVersionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.api_rounded, size: 18, color: Color(0xFF64748B)),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              context.width < 600
                  ? 'Powered by Video Platform APIs\n(Version - Upload V3)'
                  : 'Powered by Video Platform APIs (Version - Upload V3)',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({required bool isAuth}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isAuth) {
            Get.to(
              () => AuthScreen(
                isAuthenticated:
                    (homeController.mobileAuthenticated.value &&
                    !homeController.isAuthExpired.value),
              ),
            );
          } else {
            if (homeController.isFullyAuthenticated.value) {
              Get.to(() => GalleryScreen(onSelect: (_) {}));
            } else {
              showDialog(
                context: context,
                builder: (context) => const AuthenticationRequiredDialog(),
              );
            }
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isAuth
                      ? const Color(0xFFE3F2FD)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isAuth ? Icons.vpn_key_rounded : Icons.photo_library_rounded,
                  size: 28,
                  color: isAuth
                      ? const Color(0xFF1976D2)
                      : const Color(0xFF388E3C),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAuth ? 'Authentication' : 'Media Gallery',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isAuth
                          ? 'Get your access pass to use the Video Platform API'
                          : 'Browse, pick and upload your photos & videos',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: Color(0xFFBDBDBD),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGettingStartedSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  size: 22,
                  color: Color(0xFF1976D2),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Getting Started',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'This app demonstrates how the Video Platform API works for uploading media files to the cloud. '
            'Whether you\'re a business owner, developer, or just curious! '
            'Simply follow the steps below to experience how easy it is to securely upload and manage your media files.',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: const Color(0xFF6B7280),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),

          // What is TruVideo API section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What is Video Platform API?',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Think of it like a secure delivery service for your files. You give us your photos or videos, '
                  'and we safely store them in the cloud. Your files are protected, organized, and accessible whenever you need them. '
                  'Businesses use this to manage large amounts of media content without worrying about storage or security.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Steps header
          Text(
            'How It Works',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),

          // Steps
          _buildStep(
            1,
            'Log In',
            'Start by clicking on Authentication and entering your credentials (API Key and Secret Key). '
                'The system will verify your identity and give you an access token - think of it as a temporary pass '
                'that proves you\'re allowed to use the service. This token is valid for 24 hours.',
          ),
          const SizedBox(height: 18),
          _buildStep(
            2,
            'Pick Media',
            'Once logged in, head to the Media Gallery. Here you can browse through your device and select '
                'the media files you want to upload.',
          ),
          const SizedBox(height: 18),
          _buildStep(
            3,
            'Upload',
            'After selecting your files, upload your file and watch the magic happen! Your files are securely '
                'transferred to cloud storage. The app shows you real-time '
                'progress, and once complete, your media is safely stored and ready to access anytime.',
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '$number',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF343537),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
