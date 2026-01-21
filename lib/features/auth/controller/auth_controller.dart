import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
import 'package:truvideo_core_sdk/truvideo_core_sdk.dart';
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

  // SDK Authentication Controllers
  late TextEditingController sdkPayloadController;
  late TextEditingController sdkSignaturePayloadController;
  late TextEditingController sdkSignatureSecretController;
  late TextEditingController sdkSignatureController;
  late TextEditingController sdkAuthApiKeyController;
  late TextEditingController sdkAuthPayloadController;
  late TextEditingController sdkAuthSignatureController;
  late TextEditingController sdkAuthExternalIdController;

  late HomeController homeController;

  RxBool showLoading = false.obs;
  RxBool boLoading = false.obs;
  RxBool payloadVisible = false.obs;
  RxBool boPayloadVisible = false.obs;
  RxBool signatureVisible = false.obs;

  // SDK Authentication Reactive Variables
  RxBool sdkPayloadVisible = false.obs;
  RxBool sdkSignatureVisible = false.obs;
  RxBool sdkLoading = false.obs;

  static const String BACK_OFFICE_ID = 'back_office_credentials_id';
  static const String MOBILE_ID = 'mobile_credentials_id';

  RxList<CredentialsModel> savedCredentials = <CredentialsModel>[].obs;
  RxList<CredentialsModel> apiCredentials = <CredentialsModel>[].obs;
  RxList<CredentialsModel> sdkCredentials = <CredentialsModel>[].obs;
  Rx<CredentialsModel?> backOfficeCredentials = Rx<CredentialsModel?>(null);
  Rx<CredentialsModel?> mobileCredentials = Rx<CredentialsModel?>(null);
  Rx<CredentialsModel?> selectedSdkCredential = Rx<CredentialsModel?>(null);
  Rx<CredentialsModel?> selectedApiCredential = Rx<CredentialsModel?>(null);
  
  // Environment selection
  RxString selectedEnvironment = 'RC'.obs;

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

    // Initialize SDK Controllers
    sdkPayloadController = TextEditingController();
    sdkSignaturePayloadController = TextEditingController();
    sdkSignatureSecretController = TextEditingController();
    sdkSignatureController = TextEditingController();
    sdkAuthApiKeyController = TextEditingController();
    sdkAuthPayloadController = TextEditingController();
    sdkAuthSignatureController = TextEditingController();
    sdkAuthExternalIdController = TextEditingController();

    homeController = Get.find();
    // Sync environment with HomeController
    selectedEnvironment.value = homeController.selectedEnvironment.value;
    // Listen to HomeController environment changes
    ever(homeController.selectedEnvironment, (String env) {
      selectedEnvironment.value = env;
    });
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

    // Dispose SDK Controllers
    sdkPayloadController.dispose();
    sdkSignaturePayloadController.dispose();
    sdkSignatureSecretController.dispose();
    sdkSignatureController.dispose();
    sdkAuthApiKeyController.dispose();
    sdkAuthPayloadController.dispose();
    sdkAuthSignatureController.dispose();
    sdkAuthExternalIdController.dispose();

    super.onClose();
  }

  Future<void> getCredentials() async {
    try {
      final credentials = localDatabase.getCredentials();
      savedCredentials.clear();
      savedCredentials.addAll(credentials);

      // Filter API credentials by credentialType
      apiCredentials.clear();
      apiCredentials.addAll(
        credentials.where(
          (c) =>
              c.credentialType == 'API' ||
              // Backward compatibility: check old filtering logic
              (c.credentialType == null &&
                  (c.id == BACK_OFFICE_ID ||
                      (c.title?.toLowerCase().contains('api') ?? false) ||
                      (c.title?.toLowerCase().contains('back office') ?? false))),
        ),
      );

      // Filter SDK credentials by credentialType
      sdkCredentials.clear();
      sdkCredentials.addAll(
        credentials.where(
          (c) =>
              c.credentialType == 'SDK' ||
              // Backward compatibility: check old filtering logic
              (c.credentialType == null &&
                  (c.id == MOBILE_ID ||
                      (c.title?.toLowerCase().contains('sdk') ?? false) ||
                      (c.title?.toLowerCase().contains('mobile') ?? false))),
        ),
      );

      backOfficeCredentials.value = credentials.firstWhereOrNull(
        (element) => element.id == BACK_OFFICE_ID,
      );
      mobileCredentials.value = credentials.firstWhereOrNull(
        (element) => element.id == MOBILE_ID,
      );

      // Restore selected API credential if it still exists
      if (selectedApiCredential.value != null) {
        final stillExists = apiCredentials.any(
          (c) => c.id == selectedApiCredential.value?.id,
        );
        if (!stillExists) {
          selectedApiCredential.value = null;
        } else {
          // Update the reference to the current credential object
          selectedApiCredential.value = apiCredentials.firstWhere(
            (c) => c.id == selectedApiCredential.value?.id,
          );
        }
      }

      // Restore selected SDK credential if it still exists
      if (selectedSdkCredential.value != null) {
        final stillExists = sdkCredentials.any(
          (c) => c.id == selectedSdkCredential.value?.id,
        );
        if (!stillExists) {
          selectedSdkCredential.value = null;
        } else {
          // Update the reference to the current credential object
          selectedSdkCredential.value = sdkCredentials.firstWhere(
            (c) => c.id == selectedSdkCredential.value?.id,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error on fetching saved credentials: $e');
      }
    }
  }

  void useSavedCredentials(
    CredentialsModel credentials, {
    bool forBackOffice = false,
    bool fromDropdown = false,
  }) async {
    if (forBackOffice) {
      selectedApiCredential.value = credentials;
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
    // Only navigate back if not called from dropdown
    if (!fromDropdown) {
      Get.back();
    }
  }

  Future<void> changeEnvironment(String newEnvironment) async {
    // Don't do anything if environment is the same
    if (homeController.selectedEnvironment.value == newEnvironment) {
      return;
    }

    // Check if user is authenticated - always check this first
    final isAuthenticated = homeController.boAuthenticated.value;
    
    if (isAuthenticated) {
      // Show confirmation dialog - use Get.dialog with barrierDismissible: false
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text(
            'Change Environment',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Changing environment will clear your authentication. You will need to authenticate again. Do you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text(
                'Confirm',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );

      if (confirmed != true) {
        // User cancelled, don't change environment
        return;
      }

      // Clear authentication
      clearAuth();
    }

    // Update environment in HomeController (which persists it)
    await homeController.setSelectedEnvironment(newEnvironment);
    // Sync with local value (will also update via ever() listener)
    selectedEnvironment.value = newEnvironment;
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

      // Use selected environment for base URL (from HomeController)
      final baseUrl = homeController.selectedEnvironment.value == 'Prod'
          ? Endpoints.loginProdBaseUrl
          : Endpoints.loginRCBaseUrl;
      apiEndpoint.value = '$baseUrl${Endpoints.login}';
      generatedTimestamp.value = timestamp;
      generatedSignature.value = signature;
      requestBody.value = jsonBody;
      requestHeaders.value = {
        'x-authentication-api-key': boApiKeyController.text,
        'x-multitenant-external-id': boExternalIdController.text,
        'x-authentication-signature': signature,
      };

      if (kDebugMode) {
        print('Login URL: $baseUrl${Endpoints.login}');
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
        baseUrl: baseUrl,
        options: Options(
          headers: {
            'x-authentication-api-key': boApiKeyController.text,
            'x-multitenant-external-id': boExternalIdController.text,
            'x-authentication-signature': signature,
          },
        ),
      );

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

  // SDK Authentication Methods
  Future<void> generateSdkPayload() async {
    try {
      final payload = await TruvideoCoreSdk.generatePayload();
      sdkPayloadController.text = payload;
      sdkPayloadVisible.value = true;
      Utils.showToast('Payload generated successfully');
    } catch (e) {
      if (kDebugMode) {
        print('Error generating SDK payload: $e');
      }
      Utils.showToast('Failed to generate payload');
    }
  }

  Future<void> generateSdkSignature() async {
    if (sdkSignaturePayloadController.text.isEmpty ||
        sdkSignatureSecretController.text.isEmpty) {
      Utils.showToast('Payload and Secret key both are required');
      return;
    }

    try {
      List<int> secretBytes = utf8.encode(
        sdkSignatureSecretController.text.trim(),
      );
      List<int> payloadBytes = utf8.encode(
        sdkSignaturePayloadController.text.trim(),
      );
      final hmacSha256 = Hmac(sha256, secretBytes);
      final macData = hmacSha256.convert(payloadBytes);
      sdkSignatureVisible.value = true;
      sdkSignatureController.text = macData.toString();
      Utils.showToast('Signature generated successfully');
    } catch (e) {
      if (kDebugMode) {
        print("Error generating SHA256 HMAC: $e");
      }
      Utils.showToast('Failed to generate signature');
    }
  }

  Future<void> sdkAuthenticate() async {
    if (sdkAuthApiKeyController.text.isEmpty ||
        sdkAuthPayloadController.text.isEmpty ||
        sdkAuthSignatureController.text.isEmpty) {
      Utils.showToast(
        'API Key, Payload and Signature are required to authenticate',
      );
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
      sdkLoading.value = true;
      bool isAuthenticated = await TruvideoCoreSdk.isAuthenticated();
      bool isAuthExpired = await TruvideoCoreSdk.isAuthenticationExpired();

      if (!isAuthenticated || isAuthExpired) {
        await TruvideoCoreSdk.authenticate(
          apiKey: sdkAuthApiKeyController.text.trim(),
          signature: sdkAuthSignatureController.text.trim(),
          payload: sdkAuthPayloadController.text.trim(),
          externalId: sdkAuthExternalIdController.text.trim(),
        );
      }
      await TruvideoCoreSdk.initAuthentication();

      // Re-check authentication status after authentication
      bool newIsAuthenticated = await TruvideoCoreSdk.isAuthenticated();
      bool newIsAuthExpired = await TruvideoCoreSdk.isAuthenticationExpired();

      // Update home controller with latest status
      homeController.mobileAuthenticated.value = newIsAuthenticated;
      homeController.isAuthExpired.value = newIsAuthExpired;

      // Call checkAuthStatus to update fully authenticated status
      await homeController.checkAuthStatus();

      sdkLoading.value = false;

      if (newIsAuthExpired) {
        Utils.showToast('Authentication expired. Please re-authenticate.');
      } else if (newIsAuthenticated) {
        Utils.showToast('SDK Authentication Successful');
      } else {
        Utils.showToast('Authentication failed. Please try again.');
      }
    } catch (e) {
      sdkLoading.value = false;
      if (kDebugMode) {
        print('SDK Authentication failed: $e');
      }
      Get.dialog(
        ErrorDialog(
          title: 'Authentication Failed!',
          subTitle:
              'Make sure your API Key, Payload, and Signature are correct',
        ),
      );
    }
  }

  Future<void> useSavedSdkCredentials(
    CredentialsModel credentials, {
    bool fromDropdown = false,
  }) async {
    if (credentials.apiKey == null ||
        credentials.apiKey!.isEmpty ||
        credentials.secret == null ||
        credentials.secret!.isEmpty) {
      Utils.showToast('Invalid credentials: API Key and Secret are required');
      return;
    }

    // Set the selected credential
    selectedSdkCredential.value = credentials;

    try {
      // Step 1: Generate payload
      final payload = await TruvideoCoreSdk.generatePayload();
      sdkPayloadController.text = payload;
      sdkPayloadVisible.value = true;

      // Step 2: Set payload and secret for signature generation
      sdkSignaturePayloadController.text = payload;
      sdkSignatureSecretController.text = credentials.secret!;

      // Step 3: Generate signature
      List<int> secretBytes = utf8.encode(credentials.secret!);
      List<int> payloadBytes = utf8.encode(payload);
      final hmacSha256 = Hmac(sha256, secretBytes);
      final macData = hmacSha256.convert(payloadBytes);
      sdkSignatureController.text = macData.toString();
      sdkSignatureVisible.value = true;

      // Step 4: Fill all authentication fields
      sdkAuthApiKeyController.text = credentials.apiKey!;
      sdkAuthPayloadController.text = payload;
      sdkAuthSignatureController.text = macData.toString();
      sdkAuthExternalIdController.text = credentials.externalId ?? '';
    } catch (e) {
      if (kDebugMode) {
        print('Error using saved SDK credentials: $e');
      }
      Utils.showToast('Failed to load credentials');
    }

    // Only navigate back if not called from dropdown
    if (!fromDropdown) {
      Get.back();
    }
  }

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
    String? credentialType,
  }) async {
    if (apiKey.isEmpty || secretKey.isEmpty) {
      Utils.showToast('API Key and Secret are required');
      return;
    }
    if (title == null || title.trim().isEmpty) {
      Utils.showToast('Title is required');
      return;
    }

    if (forUpdate) {
      try {
        final updatedCredential = CredentialsModel(
          id: id,
          title: title,
          apiKey: apiKey,
          secret: secretKey,
          externalId: externalId,
          credentialType: credentialType,
        );
        await localDatabase.updateCredentials(updatedCredential);
        await getCredentials();
        // Don't auto-select after update - let user select manually
        Get.back();
      } catch (e) {
        if (kDebugMode) {
          print('Error on saving credentials: $e');
        }
      }
    } else {
      try {
        final uuid = Uuid();
        final newCredential = CredentialsModel(
          id: id ?? uuid.v1(),
          title: title,
          apiKey: apiKey,
          secret: secretKey,
          externalId: externalId,
          credentialType: credentialType,
        );
        await localDatabase.saveNewCredentials(newCredential);
        await getCredentials();
        // Don't auto-select after save - let user select manually from dropdown
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
