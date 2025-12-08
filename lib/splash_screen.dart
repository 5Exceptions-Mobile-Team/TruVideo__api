import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/features/home/controller/home_controller.dart';
import 'core/resourses/app_assets.dart';
import 'features/home/views/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late HomeController homeController;

  @override
  void initState() {
    homeController = Get.put(HomeController());
    navigateToHome();
    super.initState();
  }

  void navigateToHome() {
    Timer(
      const Duration(milliseconds: 3000),
      () => Get.off(() => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          AppAssets.truVideoLogo,
          width: context.width * 0.4,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
