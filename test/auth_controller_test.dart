import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:media_upload_sample_app/features/auth/controller/auth_controller.dart';
import 'package:media_upload_sample_app/features/home/controller/home_controller.dart';

class MockHomeController extends GetxController implements HomeController {
  @override
  RxBool boAuthenticated = false.obs;
  @override
  RxBool mobileAuthenticated = false.obs;
  @override
  RxBool isFullyAuthenticated = false.obs;
  @override
  RxBool isAuthExpired = false.obs;
  @override
  RxBool testingMode = false.obs;
  @override
  late GetStorage storage;

  bool clearBackOfficeAuthCalled = false;
  bool clearMobileAuthCalled = false;
  bool checkAuthStatusCalled = false;
  String? backOfficeToken;

  @override
  void checkAuthStatus({bool skipMobile = false}) {
    checkAuthStatusCalled = true;
  }

  @override
  void checkBackOfficeValidity() {}

  @override
  void clearBackOfficeAuth() {
    clearBackOfficeAuthCalled = true;
  }

  @override
  void clearMobileAuth() {
    clearMobileAuthCalled = true;
  }

  @override
  Future<void> setBackOfficeSuccess(String token) async {
    backOfficeToken = token;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthController authController;
  late MockHomeController mockHomeController;

  setUpAll(() {
    // Mock platform channels
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('PonnamKarthik/fluttertoast'),
      (MethodCall methodCall) async => true,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => '/tmp',
    );
  });

  setUp(() {
    Get.testMode = true;
    mockHomeController = MockHomeController();
    Get.put<HomeController>(mockHomeController);
    authController = AuthController();

    // Initialize controllers manually
    authController.boApiKeyController = TextEditingController();
    authController.boSecretKeyController = TextEditingController();
    authController.boExternalIdController = TextEditingController();
    authController.payloadController = TextEditingController();
    authController.signatureController = TextEditingController();
    authController.apiKeyController = TextEditingController();
    authController.externalIdController = TextEditingController();
    authController.signaturePayloadController = TextEditingController();
    authController.signatureSecretController = TextEditingController();
    authController.authApiKeyController = TextEditingController();
    authController.authPayloadController = TextEditingController();
    authController.authSignatureController = TextEditingController();
    authController.authExternalIdController = TextEditingController();
    authController.homeController = mockHomeController;
  });

  tearDown(() {
    authController.boApiKeyController.dispose();
    authController.boSecretKeyController.dispose();
    authController.boExternalIdController.dispose();
    authController.payloadController.dispose();
    authController.signatureController.dispose();
    authController.apiKeyController.dispose();
    authController.externalIdController.dispose();
    authController.signaturePayloadController.dispose();
    authController.signatureSecretController.dispose();
    authController.authApiKeyController.dispose();
    authController.authPayloadController.dispose();
    authController.authSignatureController.dispose();
    authController.authExternalIdController.dispose();
    Get.reset();
  });

  group('AuthController Initialization', () {
    test('should initialize all text controllers', () {
      expect(authController.boApiKeyController, isNotNull);
      expect(authController.boSecretKeyController, isNotNull);
      expect(authController.boExternalIdController, isNotNull);
      expect(authController.payloadController, isNotNull);
      expect(authController.signatureController, isNotNull);
      expect(authController.apiKeyController, isNotNull);
      expect(authController.externalIdController, isNotNull);
      expect(authController.signaturePayloadController, isNotNull);
      expect(authController.signatureSecretController, isNotNull);
      expect(authController.authApiKeyController, isNotNull);
      expect(authController.authPayloadController, isNotNull);
      expect(authController.authSignatureController, isNotNull);
      expect(authController.authExternalIdController, isNotNull);
    });

    test('should initialize observable values correctly', () {
      expect(authController.showLoading.value, false);
      expect(authController.boLoading.value, false);
      expect(authController.payloadVisible.value, false);
      expect(authController.boPayloadVisible.value, false);
      expect(authController.signatureVisible.value, false);
    });
  });

  group('Validation Tests', () {
    test('backOfficeAuthentication should fail with empty API key', () async {
      authController.boApiKeyController.text = '';
      authController.boSecretKeyController.text = 'secret';

      authController.backOfficeAuthentication();

      // Give async operations time to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(authController.boLoading.value, false);
    });

    test('backOfficeAuthentication should fail with empty secret key', () async {
      authController.boApiKeyController.text = 'apikey';
      authController.boSecretKeyController.text = '';

      authController.backOfficeAuthentication();

      await Future.delayed(const Duration(milliseconds: 100));

      expect(authController.boLoading.value, false);
    });

    test('authenticate should fail with empty fields', () async {
      authController.authApiKeyController.text = '';
      authController.authPayloadController.text = '';
      authController.authSignatureController.text = '';

      authController.authenticate();

      await Future.delayed(const Duration(milliseconds: 100));

      expect(authController.showLoading.value, false);
    });
  });

  group('Signature Generation', () {
    test('generateSignature should not generate with empty payload', () async {
      authController.signaturePayloadController.text = '';
      authController.signatureSecretController.text = 'secret';

      await authController.generateSignature();

      expect(authController.signatureVisible.value, false);
      expect(authController.signatureController.text, isEmpty);
    });

    test('generateSignature should not generate with empty secret', () async {
      authController.signaturePayloadController.text = 'payload';
      authController.signatureSecretController.text = '';

      await authController.generateSignature();

      expect(authController.signatureVisible.value, false);
      expect(authController.signatureController.text, isEmpty);
    });

    test('generateSignature should generate valid signature', () async {
      authController.signaturePayloadController.text = 'test_payload';
      authController.signatureSecretController.text = 'test_secret';

      await authController.generateSignature();

      expect(authController.signatureVisible.value, true);
      expect(authController.signatureController.text, isNotEmpty);
    });

    test('generateSignature should produce consistent HMAC', () async {
      authController.signaturePayloadController.text = 'test_payload';
      authController.signatureSecretController.text = 'test_secret';

      await authController.generateSignature();
      final firstSignature = authController.signatureController.text;

      await authController.generateSignature();
      final secondSignature = authController.signatureController.text;

      expect(firstSignature, equals(secondSignature));
    });

    test('generateSignature should produce correct HMAC-SHA256', () async {
      // Known test vector
      authController.signaturePayloadController.text = 'message';
      authController.signatureSecretController.text = 'key';

      await authController.generateSignature();

      // HMAC-SHA256 of "message" with key "key"
      expect(
        authController.signatureController.text,
        '6e9ef29b75fffc5b7abae527d58fdadb2fe42e7219011976917343065f58ed4a',
      );
    });
  });

  group('Clear Auth', () {
    test('clearAuth should call home controller methods', () {
      authController.clearAuth();

      expect(mockHomeController.clearBackOfficeAuthCalled, true);
      expect(mockHomeController.clearMobileAuthCalled, true);
    });
  });

  group('Copy Text', () {
    test('copyText should not throw', () {
      expect(() => authController.copyText('test text'), returnsNormally);
    });
  });

  group('Constants', () {
    test('should have correct constant values', () {
      expect(AuthController.BACK_OFFICE_ID, 'back_office_credentials_id');
      expect(AuthController.MOBILE_ID, 'mobile_credentials_id');
    });
  });
}
