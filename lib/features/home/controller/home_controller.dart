import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:media_upload_sample_app/features/gallery/controller/gallery_controller.dart';

class HomeController extends GetxController {
  RxBool isFullyAuthenticated = false.obs; // BO and Mobile
  RxBool mobileAuthenticated = false.obs; // Mobile Auth
  RxBool boAuthenticated = false.obs; // Back Office Auth
  RxBool boExpired = false.obs; // Back Office Auth
  RxBool isAuthExpired = false.obs; // Mobile Auth

  static const String BO_TOKEN_KEY = 'bo_token';
  static const String BO_TOKEN_TIMESTAMP_KEY = 'bo_token_timestamp';

  bool enableTruVideoSdk = false;

  GetStorage storage = GetStorage();

  @override
  void onInit() {
    // checkAuthStatus();
    checkBackOfficeValidity();
    Get.put(GalleryController());
    super.onInit();
  }

  // void checkAuthStatus({bool skipMobile = false}) async {
  //   mobileAuthenticated.value = await TruvideoCoreSdk.isAuthenticated();
  //   isAuthExpired.value = await TruvideoCoreSdk.isAuthenticationExpired();
  //
  //   if (!skipMobile && mobileAuthenticated.value && !isAuthExpired.value) {
  //     await TruvideoCoreSdk.initAuthentication();
  //   }
  //
  //   checkBackOfficeValidity();
  //
  //   isFullyAuthenticated.value =
  //       mobileAuthenticated.value &&
  //       !isAuthExpired.value &&
  //       boAuthenticated.value;
  // }

  void checkBackOfficeValidity() {
    String? token = storage.read(BO_TOKEN_KEY);
    String? timestampStr = storage.read(BO_TOKEN_TIMESTAMP_KEY);

    if (token != null && timestampStr != null) {
      DateTime timestamp = DateTime.parse(timestampStr);
      Duration difference = DateTime.now().difference(timestamp);

      if (difference.inHours < 23) {
        boAuthenticated.value = true;
        isFullyAuthenticated.value = true;
        boExpired.value = false;
      } else {
        boExpired.value = true;
        clearBackOfficeAuth();
      }
    } else {
      boAuthenticated.value = false;
      isFullyAuthenticated.value = false;
    }
  }

  Future<void> setBackOfficeSuccess(String token) async {
    await storage.write(BO_TOKEN_KEY, token);
    await storage.write(
      BO_TOKEN_TIMESTAMP_KEY,
      DateTime.now().toIso8601String(),
    );
    boAuthenticated.value = true;
    isFullyAuthenticated.value = true;
    isAuthExpired.value = false;
    // checkAuthStatus(skipMobile: true);
  }

  void clearBackOfficeAuth() async {
    await storage.remove(BO_TOKEN_KEY);
    await storage.remove(BO_TOKEN_TIMESTAMP_KEY);
    isFullyAuthenticated.value = false;
    boAuthenticated.value = false;
    // Clear the auth response when clearing auth
    // try {
    //   final authController = Get.find<AuthController>();
    //   authController.backOfficeAuthResponse.value = null;
    // } catch (e) {
    //   // AuthController might not be initialized, ignore
    // }
    // checkAuthStatus(skipMobile: true);
  }

  void clearMobileAuth() async {
    // await TruvideoCoreSdk.clearAuthentication();
    // checkAuthStatus(skipMobile: true);
  }
}
