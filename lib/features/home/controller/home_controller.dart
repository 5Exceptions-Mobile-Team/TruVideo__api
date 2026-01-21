import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:media_upload_sample_app/features/gallery/controller/gallery_controller.dart';
import 'package:truvideo_core_sdk/truvideo_core_sdk.dart';

class HomeController extends GetxController {
  RxBool isFullyAuthenticated = false.obs; // BO and Mobile
  RxBool mobileAuthenticated = false.obs; // Mobile Auth
  RxBool boAuthenticated = false.obs; // Back Office Auth
  RxBool boExpired = false.obs; // Back Office Auth
  RxBool isAuthExpired = false.obs; // Mobile Auth

  static const String BO_TOKEN_KEY = 'bo_token';
  static const String BO_TOKEN_TIMESTAMP_KEY = 'bo_token_timestamp';
  static const String SELECTED_ENVIRONMENT_KEY = 'selected_environment';

  bool enableTruVideoSdk = false;

  GetStorage storage = GetStorage();
  
  // Environment selection
  RxString selectedEnvironment = 'RC'.obs;

  @override
  void onInit() {
    // Load saved environment or default to RC - ensure it persists
    final savedEnv = storage.read<String>(SELECTED_ENVIRONMENT_KEY);
    if (savedEnv != null && (savedEnv == 'RC' || savedEnv == 'Prod')) {
      selectedEnvironment.value = savedEnv;
    } else {
      selectedEnvironment.value = 'RC';
      storage.write(SELECTED_ENVIRONMENT_KEY, 'RC');
    }
    checkAuthStatus();
    checkBackOfficeValidity();
    Get.put(GalleryController());
    super.onInit();
  }
  
  Future<void> setSelectedEnvironment(String environment) async {
    if (environment == 'RC' || environment == 'Prod') {
      selectedEnvironment.value = environment;
      await storage.write(SELECTED_ENVIRONMENT_KEY, environment);
    }
  }

  Future<void> checkAuthStatus({bool skipMobile = false}) async {
    // Only check SDK authentication on mobile platforms
    if (!kIsWeb) {
      mobileAuthenticated.value = await TruvideoCoreSdk.isAuthenticated();
      isAuthExpired.value = await TruvideoCoreSdk.isAuthenticationExpired();

      if (!skipMobile && mobileAuthenticated.value && !isAuthExpired.value) {
        await TruvideoCoreSdk.initAuthentication();
      }
    } else {
      // On web, SDK is not available, so mobile auth is not applicable
      mobileAuthenticated.value = false;
      isAuthExpired.value = false;
    }

    checkBackOfficeValidity();

    // For mobile: both API and SDK auth required
    // For web: only API auth required
    if (kIsWeb) {
      isFullyAuthenticated.value = boAuthenticated.value;
    } else {
      isFullyAuthenticated.value =
          mobileAuthenticated.value &&
          !isAuthExpired.value &&
          boAuthenticated.value;
    }
  }

  void checkBackOfficeValidity() {
    String? token = storage.read(BO_TOKEN_KEY);
    String? timestampStr = storage.read(BO_TOKEN_TIMESTAMP_KEY);

    if (token != null && timestampStr != null) {
      DateTime timestamp = DateTime.parse(timestampStr);
      Duration difference = DateTime.now().difference(timestamp);

      if (difference.inHours < 23) {
        boAuthenticated.value = true;
        boExpired.value = false;
      } else {
        boExpired.value = true;
        clearBackOfficeAuth();
      }
    } else {
      boAuthenticated.value = false;
    }
    
    // Update fully authenticated status based on platform
    if (kIsWeb) {
      isFullyAuthenticated.value = boAuthenticated.value;
    } else {
      isFullyAuthenticated.value =
          mobileAuthenticated.value &&
          !isAuthExpired.value &&
          boAuthenticated.value;
    }
  }

  Future<void> setBackOfficeSuccess(String token) async {
    await storage.write(BO_TOKEN_KEY, token);
    await storage.write(
      BO_TOKEN_TIMESTAMP_KEY,
      DateTime.now().toIso8601String(),
    );
    boAuthenticated.value = true;
    isAuthExpired.value = false;
    checkAuthStatus(skipMobile: true);
  }

  void clearBackOfficeAuth() async {
    await storage.remove(BO_TOKEN_KEY);
    await storage.remove(BO_TOKEN_TIMESTAMP_KEY);
    boAuthenticated.value = false;
    // Clear the auth response when clearing auth
    // try {
    //   final authController = Get.find<AuthController>();
    //   authController.backOfficeAuthResponse.value = null;
    // } catch (e) {
    //   // AuthController might not be initialized, ignore
    // }
    checkAuthStatus(skipMobile: true);
  }

  Future<void> clearMobileAuth() async {
    if (!kIsWeb) {
      await TruvideoCoreSdk.clearAuthentication();
    }
    mobileAuthenticated.value = false;
    isAuthExpired.value = false;
    checkAuthStatus(skipMobile: true);
  }
}
