import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:media_upload_sample_app/core/utils/utils.dart';
import 'package:media_upload_sample_app/features/auth/controller/auth_controller.dart';
import 'package:truvideo_core_sdk/truvideo_core_sdk.dart';

class HomeController extends GetxController {
  RxBool isFullyAuthenticated = false.obs; // BO and Mobile
  RxBool mobileAuthenticated = false.obs; // Mobile Auth
  RxBool boAuthenticated = false.obs; // Back Office Auth
  RxBool isAuthExpired = false.obs; // Mobile Auth
  RxBool testingMode =
      false.obs; // Testing Mode - controls JSON response display

  static const String BO_TOKEN_KEY = 'bo_token';
  static const String BO_TOKEN_TIMESTAMP_KEY = 'bo_token_timestamp';
  static const String TESTING_MODE_KEY = 'testing_mode';

  GetStorage storage = GetStorage();

  @override
  void onInit() {
    checkAuthStatus();
    // Load testing mode preference from storage
    testingMode.value = storage.read(TESTING_MODE_KEY) ?? false;
    super.onInit();
  }

  void checkAuthStatus({bool skipMobile = false}) async {
    mobileAuthenticated.value = await TruvideoCoreSdk.isAuthenticated();
    isAuthExpired.value = await TruvideoCoreSdk.isAuthenticationExpired();

    if (!skipMobile && mobileAuthenticated.value && !isAuthExpired.value) {
      await TruvideoCoreSdk.initAuthentication();
    }

    checkBackOfficeValidity();

    isFullyAuthenticated.value =
        mobileAuthenticated.value &&
        !isAuthExpired.value &&
        boAuthenticated.value;
  }

  void checkBackOfficeValidity() {
    String? token = storage.read(BO_TOKEN_KEY);
    String? timestampStr = storage.read(BO_TOKEN_TIMESTAMP_KEY);

    if (token != null && timestampStr != null) {
      DateTime timestamp = DateTime.parse(timestampStr);
      Duration difference = DateTime.now().difference(timestamp);

      if (difference.inHours < 23) {
        boAuthenticated.value = true;
      } else {
        clearBackOfficeAuth();
      }
    } else {
      boAuthenticated.value = false;
    }
  }

  Future<void> setBackOfficeSuccess(String token) async {
    await storage.write(BO_TOKEN_KEY, token);
    await storage.write(
      BO_TOKEN_TIMESTAMP_KEY,
      DateTime.now().toIso8601String(),
    );
    boAuthenticated.value = true;
    checkAuthStatus(skipMobile: true);
  }

  void clearBackOfficeAuth() {
    storage.remove(BO_TOKEN_KEY);
    storage.remove(BO_TOKEN_TIMESTAMP_KEY);
    boAuthenticated.value = false;
    // Clear the auth response when clearing auth
    try {
      final authController = Get.find<AuthController>();
      authController.backOfficeAuthResponse.value = null;
    } catch (e) {
      // AuthController might not be initialized, ignore
    }
    checkAuthStatus(skipMobile: true);
  }

  void clearMobileAuth() async {
    await TruvideoCoreSdk.clearAuthentication();
    checkAuthStatus(skipMobile: true);
  }
}
