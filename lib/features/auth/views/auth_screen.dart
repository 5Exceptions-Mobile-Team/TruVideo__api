import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/core/resourses/pallet.dart';
import 'package:media_upload_sample_app/features/auth/controller/auth_controller.dart';
import 'package:media_upload_sample_app/features/auth/widgets/interactive_api_console.dart';
import 'package:media_upload_sample_app/features/auth/widgets/parameter_description_card.dart';
import 'package:media_upload_sample_app/features/auth/widgets/request_response_samples.dart';
import 'package:media_upload_sample_app/features/common/widgets/common_app_bar.dart';
import 'package:media_upload_sample_app/features/common/widgets/gradient_background.dart';

class AuthScreen extends StatefulWidget {
  final bool isAuthenticated;
  const AuthScreen({super.key, required this.isAuthenticated});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late AuthController authController;

  @override
  void initState() {
    authController = Get.put(AuthController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CommonAppBar(
          title: 'Generate an API Token',
          leading: Semantics(
            identifier: 'back_button',
            label: 'back_button',
            child: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Adaptive layout: split screen on desktop (≥768px), single column on mobile
              final isDesktop = constraints.maxWidth >= 768;

              if (isDesktop) {
                return _buildDesktopLayout();
              } else {
                return _buildMobileLayout();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    final useAnimations = !kIsWeb;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Panel - Request Details & Parameter Descriptions
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (useAnimations)
                  const ParameterDescriptionCard()
                      .animate()
                      .fadeIn(delay: 100.ms)
                      .slideX(begin: -0.2)
                else
                  const ParameterDescriptionCard(),
              ],
            ),
          ),
        ),

        // Divider
        Container(width: 1, color: Pallet.glassBorder.withOpacity(0.3)),

        // Right Panel - Interactive Console & Request/Response Samples
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (useAnimations)
                  const InteractiveApiConsole()
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .slideX(begin: 0.2)
                else
                  const InteractiveApiConsole(),
                const SizedBox(height: 24),
                if (useAnimations)
                  const RequestResponseSamples().animate().fadeIn(delay: 300.ms)
                else
                  const RequestResponseSamples(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    final useAnimations = !kIsWeb;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Parameter Descriptions
          if (useAnimations)
            const ParameterDescriptionCard()
                .animate()
                .fadeIn(delay: 100.ms)
                .slideY(begin: -0.1)
          else
            const ParameterDescriptionCard(),
          const SizedBox(height: 24),

          // Interactive Console
          if (useAnimations)
            const InteractiveApiConsole()
                .animate()
                .fadeIn(delay: 200.ms)
                .slideY(begin: 0.1)
          else
            const InteractiveApiConsole(),
          const SizedBox(height: 24),

          // Request/Response Samples
          if (useAnimations)
            const RequestResponseSamples().animate().fadeIn(delay: 300.ms)
          else
            const RequestResponseSamples(),
        ],
      ),
    );
  }
}
