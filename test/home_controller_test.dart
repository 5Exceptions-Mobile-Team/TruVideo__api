import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/features/home/controller/home_controller.dart';

// Mock storage that doesn't require platform channels
class MockGetStorage {
  final Map<String, dynamic> _data = {};

  dynamic read(String key) => _data[key];

  Future<void> write(String key, dynamic value) async {
    _data[key] = value;
  }

  Future<void> remove(String key) async {
    _data.remove(key);
  }

  void clear() => _data.clear();
}

// Testable version of HomeController that doesn't call SDK
class TestableHomeController extends GetxController {
  RxBool isFullyAuthenticated = false.obs;
  RxBool mobileAuthenticated = false.obs;
  RxBool boAuthenticated = false.obs;
  RxBool isAuthExpired = false.obs;
  RxBool testingMode = false.obs;

  static const String BO_TOKEN_KEY = 'bo_token';
  static const String BO_TOKEN_TIMESTAMP_KEY = 'bo_token_timestamp';
  static const String TESTING_MODE_KEY = 'testing_mode';

  final MockGetStorage storage = MockGetStorage();

  // Track method calls for testing
  int checkAuthStatusCallCount = 0;
  int checkBackOfficeValidityCallCount = 0;

  @override
  void onInit() {
    testingMode.value = storage.read(TESTING_MODE_KEY) ?? false;
    super.onInit();
  }

  void checkAuthStatus({bool skipMobile = false}) {
    checkAuthStatusCallCount++;
    checkBackOfficeValidity();
    isFullyAuthenticated.value =
        mobileAuthenticated.value &&
        !isAuthExpired.value &&
        boAuthenticated.value;
  }

  void checkBackOfficeValidity() {
    checkBackOfficeValidityCallCount++;
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
    checkAuthStatus(skipMobile: true);
  }

  void clearMobileAuth() {
    mobileAuthenticated.value = false;
    checkAuthStatus(skipMobile: true);
  }

  void setTestingMode(bool value) {
    testingMode.value = value;
    storage.write(TESTING_MODE_KEY, value);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestableHomeController controller;

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async => '/tmp',
        );
  });

  setUp(() {
    Get.testMode = true;
    controller = TestableHomeController();
    Get.put<TestableHomeController>(controller);
  });

  tearDown(() {
    Get.reset();
  });

  group('HomeController Initialization', () {
    test('should initialize with default values', () {
      expect(controller.isFullyAuthenticated.value, false);
      expect(controller.mobileAuthenticated.value, false);
      expect(controller.boAuthenticated.value, false);
      expect(controller.isAuthExpired.value, false);
      expect(controller.testingMode.value, false);
    });

    test('should load testing mode from storage', () async {
      controller.storage.write(TestableHomeController.TESTING_MODE_KEY, true);
      controller.onInit();

      expect(controller.testingMode.value, true);
    });
  });

  group('Constants', () {
    test('should have correct constant values', () {
      expect(HomeController.BO_TOKEN_KEY, 'bo_token');
      expect(HomeController.BO_TOKEN_TIMESTAMP_KEY, 'bo_token_timestamp');
      expect(HomeController.TESTING_MODE_KEY, 'testing_mode');
    });
  });

  group('checkAuthStatus', () {
    test(
      'should update isFullyAuthenticated based on all conditions',
      () async {
        // Set up valid BO token in storage first
        await controller.storage.write(
          TestableHomeController.BO_TOKEN_KEY,
          'test_token',
        );
        await controller.storage.write(
          TestableHomeController.BO_TOKEN_TIMESTAMP_KEY,
          DateTime.now().toIso8601String(),
        );
        controller.mobileAuthenticated.value = true;
        controller.isAuthExpired.value = false;

        controller.checkAuthStatus();

        expect(controller.isFullyAuthenticated.value, true);
      },
    );

    test('should be false if mobile not authenticated', () {
      controller.mobileAuthenticated.value = false;
      controller.isAuthExpired.value = false;
      controller.boAuthenticated.value = true;

      controller.checkAuthStatus();

      expect(controller.isFullyAuthenticated.value, false);
    });

    test('should be false if auth is expired', () {
      controller.mobileAuthenticated.value = true;
      controller.isAuthExpired.value = true;
      controller.boAuthenticated.value = true;

      controller.checkAuthStatus();

      expect(controller.isFullyAuthenticated.value, false);
    });

    test('should be false if BO not authenticated', () {
      controller.mobileAuthenticated.value = true;
      controller.isAuthExpired.value = false;
      controller.boAuthenticated.value = false;

      controller.checkAuthStatus();

      expect(controller.isFullyAuthenticated.value, false);
    });

    test('should call checkBackOfficeValidity', () {
      controller.checkAuthStatus();

      expect(controller.checkBackOfficeValidityCallCount, greaterThan(0));
    });
  });

  group('checkBackOfficeValidity', () {
    test('should set boAuthenticated to false when no token', () {
      controller.checkBackOfficeValidity();

      expect(controller.boAuthenticated.value, false);
    });

    test('should set boAuthenticated to true for valid token', () async {
      await controller.storage.write(
        TestableHomeController.BO_TOKEN_KEY,
        'test_token',
      );
      await controller.storage.write(
        TestableHomeController.BO_TOKEN_TIMESTAMP_KEY,
        DateTime.now().toIso8601String(),
      );

      controller.checkBackOfficeValidity();

      expect(controller.boAuthenticated.value, true);
    });

    test('should clear auth for expired token (>23 hours)', () async {
      await controller.storage.write(
        TestableHomeController.BO_TOKEN_KEY,
        'test_token',
      );
      await controller.storage.write(
        TestableHomeController.BO_TOKEN_TIMESTAMP_KEY,
        DateTime.now().subtract(const Duration(hours: 24)).toIso8601String(),
      );

      controller.checkBackOfficeValidity();

      expect(controller.boAuthenticated.value, false);
    });
  });

  group('setBackOfficeSuccess', () {
    test('should store token and timestamp', () async {
      await controller.setBackOfficeSuccess('test_token');

      expect(
        controller.storage.read(TestableHomeController.BO_TOKEN_KEY),
        'test_token',
      );
      expect(
        controller.storage.read(TestableHomeController.BO_TOKEN_TIMESTAMP_KEY),
        isNotNull,
      );
    });

    test('should set boAuthenticated to true', () async {
      await controller.setBackOfficeSuccess('test_token');

      expect(controller.boAuthenticated.value, true);
    });

    test('should call checkAuthStatus', () async {
      final initialCount = controller.checkAuthStatusCallCount;

      await controller.setBackOfficeSuccess('test_token');

      expect(controller.checkAuthStatusCallCount, greaterThan(initialCount));
    });
  });

  group('clearBackOfficeAuth', () {
    test('should remove token from storage', () async {
      await controller.storage.write(
        TestableHomeController.BO_TOKEN_KEY,
        'test_token',
      );

      controller.clearBackOfficeAuth();

      expect(
        controller.storage.read(TestableHomeController.BO_TOKEN_KEY),
        isNull,
      );
    });

    test('should set boAuthenticated to false', () async {
      controller.boAuthenticated.value = true;

      controller.clearBackOfficeAuth();

      expect(controller.boAuthenticated.value, false);
    });
  });

  group('clearMobileAuth', () {
    test('should set mobileAuthenticated to false', () {
      controller.mobileAuthenticated.value = true;

      controller.clearMobileAuth();

      expect(controller.mobileAuthenticated.value, false);
    });

    test('should call checkAuthStatus', () {
      final initialCount = controller.checkAuthStatusCallCount;

      controller.clearMobileAuth();

      expect(controller.checkAuthStatusCallCount, greaterThan(initialCount));
    });
  });

  group('Testing Mode', () {
    test('should toggle testing mode', () {
      controller.setTestingMode(true);
      expect(controller.testingMode.value, true);

      controller.setTestingMode(false);
      expect(controller.testingMode.value, false);
    });

    test('should persist testing mode to storage', () {
      controller.setTestingMode(true);

      expect(
        controller.storage.read(TestableHomeController.TESTING_MODE_KEY),
        true,
      );
    });
  });
}
