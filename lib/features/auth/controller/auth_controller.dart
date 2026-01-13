import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:media_upload_sample_app/core/resourses/endpoints.dart';
import 'package:media_upload_sample_app/core/services/api_service.dart';
import 'package:media_upload_sample_app/core/services/connectivity_service.dart';
import 'package:media_upload_sample_app/core/services/local_database_service.dart';
import 'package:media_upload_sample_app/core/utils/utils.dart';
import 'package:media_upload_sample_app/features/auth/models/credentials_model.dart';
import 'package:media_upload_sample_app/features/common/widgets/error_widget.dart';
import 'package:media_upload_sample_app/features/home/controller/home_controller.dart';
import 'package:uuid/uuid.dart';

class AuthController extends GetxController {
  GetStorage storage = GetStorage();
  LocalDatabase localDatabase = LocalDatabase();
  ApiService apiService = ApiService();
  ConnectivityService connectivityService = ConnectivityService();

  late TextEditingController boApiKeyController;
  late TextEditingController boSecretKeyController;
  late TextEditingController boExternalIdController;
  late TextEditingController payloadController;
  late TextEditingController signatureController;
  late TextEditingController apiKeyController;
  late TextEditingController externalIdController;
  late TextEditingController signaturePayloadController;
  late TextEditingController signatureSecretController;
  late TextEditingController authApiKeyController;
  late TextEditingController authPayloadController;
  late TextEditingController authSignatureController;
  late TextEditingController authExternalIdController;

  late HomeController homeController;

  RxBool showLoading = false.obs;
  RxBool boLoading = false.obs;
  RxBool payloadVisible = false.obs;
  RxBool boPayloadVisible = false.obs;
  RxBool signatureVisible = false.obs;

  static const String BACK_OFFICE_ID = 'back_office_credentials_id';
  static const String MOBILE_ID = 'mobile_credentials_id';

  RxList<CredentialsModel> savedCredentials = <CredentialsModel>[].obs;
  Rx<CredentialsModel?> backOfficeCredentials = Rx<CredentialsModel?>(null);
  Rx<CredentialsModel?> mobileCredentials = Rx<CredentialsModel?>(null);

  // Store back office authentication response
  Rx<Map<String, dynamic>?> backOfficeAuthResponse = Rx<Map<String, dynamic>?>(
    null,
  );

  // Store request details for UI display
  Rx<Map<String, dynamic>?> requestBody = Rx<Map<String, dynamic>?>(null);
  Rx<Map<String, String>?> requestHeaders = Rx<Map<String, String>?>(null);
  RxString generatedTimestamp = ''.obs;
  RxString generatedSignature = ''.obs;
  RxString apiEndpoint = ''.obs;

  @override
  void onInit() {
    boApiKeyController = TextEditingController();
    boSecretKeyController = TextEditingController();
    boExternalIdController = TextEditingController();
    payloadController = TextEditingController();
    signatureController = TextEditingController();
    apiKeyController = TextEditingController();
    externalIdController = TextEditingController();
    signaturePayloadController = TextEditingController();
    signatureSecretController = TextEditingController();
    authApiKeyController = TextEditingController();
    authPayloadController = TextEditingController();
    authSignatureController = TextEditingController();
    authExternalIdController = TextEditingController();
    homeController = Get.find();
    getCredentials();
    super.onInit();
  }

  @override
  void onClose() {
    boApiKeyController.dispose();
    boSecretKeyController.dispose();
    boExternalIdController.dispose();
    payloadController.dispose();
    signatureController.dispose();
    apiKeyController.dispose();
    externalIdController.dispose();
    signaturePayloadController.dispose();
    signatureSecretController.dispose();
    authApiKeyController.dispose();
    authPayloadController.dispose();
    authSignatureController.dispose();
    authExternalIdController.dispose();
    super.onClose();
  }

  void getCredentials() async {
    try {
      final credentials = localDatabase.getCredentials();
      savedCredentials.clear();
      savedCredentials.addAll(credentials);

      backOfficeCredentials.value = credentials.firstWhereOrNull(
        (element) => element.id == BACK_OFFICE_ID,
      );
      mobileCredentials.value = credentials.firstWhereOrNull(
        (element) => element.id == MOBILE_ID,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error on fetching saved credentials: $e');
      }
    }
  }

  void useSavedCredentials(
    CredentialsModel credentials, {
    bool forBackOffice = false,
  }) async {
    if (forBackOffice) {
      homeController.clearBackOfficeAuth();
      resetDisplayData();
      boApiKeyController.text = credentials.apiKey!;
      boSecretKeyController.text = credentials.secret!;
      boExternalIdController.text = credentials.externalId!;
    } else {
      // await generatePayload(
      //   fromSavedCredentials: true,
      //   secretKey: credentials.secret,
      // );
      // await generateSignature();
      //
      // authApiKeyController.text = credentials.apiKey!;
      // authPayloadController.text = payloadController.text;
      // authSignatureController.text = signatureController.text;
      // authExternalIdController.text = credentials.externalId!;
    }
    Get.back();
  }

  void backOfficeAuthentication() async {
    if (boApiKeyController.text.isEmpty || boSecretKeyController.text.isEmpty) {
      Utils.showToast('API Key and Secret Key both are required');
      return;
    }
    if (!await connectivityService.hasConnection()) {
      Get.dialog(
        ErrorDialog(
          title: 'Internet Error',
          subTitle: 'Make sure you have stable internet connection',
        ),
      );
      return;
    }

    try {
      boLoading.value = true;
      // Get UTC time and format it to match the technical documentation example (3 decimal places for ms + Z)
      DateTime now = DateTime.now().toUtc();
      String timestamp = "${now.toIso8601String().substring(0, 23)}Z";

      Map<String, dynamic> jsonBody = {'timestamp': timestamp};
      String compactJson = jsonEncode(jsonBody);

      List<int> keyBytes = utf8.encode(boSecretKeyController.text);
      List<int> messageBytes = utf8.encode(compactJson);
      Hmac hmac = Hmac(sha256, keyBytes);
      Digest digest = hmac.convert(messageBytes);
      String signature = digest.toString();

      // Store request details for UI display
      apiEndpoint.value = '${Endpoints.loginBaseUrl}${Endpoints.login}';
      generatedTimestamp.value = timestamp;
      generatedSignature.value = signature;
      requestBody.value = jsonBody;
      requestHeaders.value = {
        'x-authentication-api-key': boApiKeyController.text,
        'x-multitenant-external-id': boExternalIdController.text,
        'x-authentication-signature': signature,
      };

      if (kDebugMode) {
        print('Login URL: ${Endpoints.loginBaseUrl}${Endpoints.login}');
        print('Headers: x-authentication-api-key: ${boApiKeyController.text}');
        print(
          'Headers: x-multitenant-external-id: ${boExternalIdController.text}',
        );
        print('Headers: x-authentication-signature: $signature');
        print("jsonBody: $jsonBody");
      }

      final res = await apiService.post(
        path: Endpoints.login,
        data: jsonBody,
        options: Options(
          headers: {
            'x-authentication-api-key': boApiKeyController.text,
            'x-multitenant-external-id': boExternalIdController.text,
            'x-authentication-signature': signature,
          },
        ),
      );

      if (kDebugMode) {
        print('/////////////////////////////');
        print(res);
      }

      if (res != null && res['accessToken'] != null) {
        String token = res['accessToken'];
        // Store the full response for JSON display
        backOfficeAuthResponse.value = res as Map<String, dynamic>?;
        homeController.setBackOfficeSuccess(token);
        // homeController.checkAuthStatus();
      } else {
        backOfficeAuthResponse.value = null;
      }
      boLoading.value = false;
    } catch (e) {
      boLoading.value = false;
      // Clear response on error
      backOfficeAuthResponse.value = null;
      if (kDebugMode) {
        print('Authentication failed: $e');
      }
      Get.dialog(
        ErrorDialog(
          title: 'Authentication Failed!',
          subTitle: 'Make sure your API and Secret key are correct',
        ),
      );
    }
  }

  // Future<void> generatePayload({
  //   bool fromSavedCredentials = false,
  //   String? secretKey,
  // }) async {
  //   final payload = await TruvideoCoreSdk.generatePayload();
  //   payloadController.text = payload;
  //   payloadVisible.value = true;
  //   if (fromSavedCredentials) {
  //     signaturePayloadController.text = payloadController.text;
  //     signatureSecretController.text = secretKey!;
  //   }
  // }

  // Future<void> generateSignature() async {
  //   if (signaturePayloadController.text.isEmpty ||
  //       signatureSecretController.text.isEmpty) {
  //     Utils.showToast('Payload and Secret key both are required');
  //     return;
  //   }
  //
  //   try {
  //     List<int> secretBytes = utf8.encode(
  //       signatureSecretController.text.trim(),
  //     );
  //     List<int> payloadBytes = utf8.encode(
  //       signaturePayloadController.text.trim(),
  //     );
  //     final hmacSha256 = Hmac(sha256, secretBytes);
  //     final macData = hmacSha256.convert(payloadBytes);
  //     signatureVisible.value = true;
  //     signatureController.text = macData.toString();
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("Error generating SHA256 HMAC: $e");
  //     }
  //   }
  // }

  // void authenticate() async {
  //   if (authApiKeyController.text.isEmpty ||
  //       authPayloadController.text.isEmpty ||
  //       authSignatureController.text.isEmpty) {
  //     Utils.showToast(
  //       'API Key, Payload and Signature are required to authenticate',
  //       length: Toast.LENGTH_LONG,
  //     );
  //     return;
  //   }
  //   if (!await ConnectivityService().hasConnection()) {
  //     Get.dialog(
  //       ErrorDialog(
  //         title: 'Internet Error',
  //         subTitle: 'Make sure you have stable internet connection',
  //       ),
  //     );
  //     return;
  //   }
  //   try {
  //     showLoading.value = true;
  //     bool isAuthenticated = await TruvideoCoreSdk.isAuthenticated();
  //     bool isAuthExpired = await TruvideoCoreSdk.isAuthenticationExpired();
  //
  //     if (!isAuthenticated || isAuthExpired) {
  //       await TruvideoCoreSdk.authenticate(
  //         apiKey: authApiKeyController.text.trim(),
  //         signature: authSignatureController.text.trim(),
  //         payload: authPayloadController.text.trim(),
  //         externalId: authExternalIdController.text.trim(),
  //       );
  //     }
  //     await TruvideoCoreSdk.initAuthentication();
  //     homeController.checkAuthStatus();
  //     showLoading.value = false;
  //     Utils.showToast('Mobile Authentication Successfully');
  //   } catch (e) {
  //     showLoading.value = false;
  //     if (kDebugMode) {
  //       print('Authentication failed: $e');
  //     }
  //     Get.dialog(
  //       ErrorDialog(
  //         title: 'Authentication Failed!',
  //         subTitle: 'Make sure your API and Secret key are correct',
  //       ),
  //     );
  //   }
  // }

  void copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  void saveUpdateCredentials(
    bool forUpdate,
    String apiKey,
    String secretKey,
    String externalId, {
    String? id,
    String? title,
  }) async {
    if (apiKey.isEmpty || secretKey.isEmpty) {
      Utils.showToast('API Key and Secret are required');
      return;
    }

    if (forUpdate) {
      try {
        await localDatabase.updateCredentials(
          CredentialsModel(
            id: id,
            title: title,
            apiKey: apiKey,
            secret: secretKey,
            externalId: externalId,
          ),
        );
        getCredentials();
        Get.back();
      } catch (e) {
        if (kDebugMode) {
          print('Error on saving credentials: $e');
        }
      }
    } else {
      try {
        final uuid = Uuid();
        await localDatabase.saveNewCredentials(
          CredentialsModel(
            id: id ?? uuid.v1(),
            title: title,
            apiKey: apiKey,
            secret: secretKey,
            externalId: externalId,
          ),
        );
        getCredentials();
        Get.back();
      } catch (e) {
        if (kDebugMode) {
          print('Error on saving credentials: $e');
        }
      }
    }
  }

  void deleteCredentials(String id) async {
    try {
      await localDatabase.deleteCredentials(id);
      getCredentials();
    } catch (e) {
      if (kDebugMode) {
        print('Error on deleting credentials: $e');
      }
    }
  }

  void clearAuth() async {
    homeController.clearBackOfficeAuth();
    homeController.clearMobileAuth();
    resetDisplayData();
  }

  void resetDisplayData() {
    requestBody.value = null;
    requestHeaders.value = null;
    backOfficeAuthResponse.value = null;
    generatedTimestamp.value = '';
    generatedSignature.value = '';
    apiEndpoint.value = '';
  }
}
