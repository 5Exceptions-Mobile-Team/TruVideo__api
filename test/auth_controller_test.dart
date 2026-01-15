import 'dart:async';
import 'package:dio/dio.dart';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:media_upload_sample_app/core/services/api_service.dart';
import 'package:media_upload_sample_app/core/services/connectivity_service.dart';
import 'package:media_upload_sample_app/core/services/local_database_service.dart';
import 'package:media_upload_sample_app/features/auth/controller/auth_controller.dart';
import 'package:media_upload_sample_app/features/auth/models/credentials_model.dart';
import 'package:media_upload_sample_app/features/home/controller/home_controller.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Fakes
class TestLocalDatabase implements LocalDatabase {
  List<CredentialsModel> mockCredentials = [];

  @override
  Box<CredentialsModel>? credentialsBox;

  @override
  Future<void> openLocalDB() async {}

  @override
  Future<void> closeLocalDb() async {}

  @override
  List<CredentialsModel> getCredentials() => mockCredentials;

  @override
  Future<void> saveNewCredentials(CredentialsModel credentials) async {
    mockCredentials.add(credentials);
  }

  @override
  Future<void> updateCredentials(CredentialsModel credentials) async {
    final index = mockCredentials.indexWhere((c) => c.id == credentials.id);
    if (index != -1) {
      mockCredentials[index] = credentials;
    }
  }

  @override
  Future<void> deleteCredentials(String id) async {
    mockCredentials.removeWhere((c) => c.id == id);
  }
}

class TestConnectivityService implements ConnectivityService {
  bool _hasConnection = true;

  void setHasConnection(bool value) {
    _hasConnection = value;
  }

  @override
  Future<bool> hasConnection() async => _hasConnection;

  @override
  Future<List<ConnectivityResult>> getConnectivityType() async => [
    ConnectivityResult.wifi,
  ];

  @override
  Future<bool> hasInternetAccess() async => _hasConnection;

  @override
  Future<bool> isConnectedToMobileData() async => false;

  @override
  Future<bool> isConnectedToWifi() async => true;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Stream.value([ConnectivityResult.wifi]);
}

class TestApiService implements ApiService {
  final Future<dynamic> Function(String path, dynamic data)? postMock;
  TestApiService({this.postMock});

  @override
  late Dio dio;

  @override
  Dio createDio({String? baseUrl, String? token, bool logBody = true}) {
    return Dio();
  }

  @override
  Future<T?> get<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? token,
    String? baseUrl,
  }) async {
    return null;
  }

  @override
  Future<T?> post<T>({
    required String path,
    required dynamic data,
    Options? options,
    String? token,
    String? baseUrl,
  }) async {
    if (postMock != null) {
      final res = await postMock!(path, data);
      return res as T?;
    }
    return null;
  }

  @override
  Future<T?> put<T>({
    required String path,
    required dynamic data,
    Options? options,
    String? token,
    String? baseUrl,
  }) async {
    return null;
  }
}

class TestHomeController extends GetxController implements HomeController {
  @override
  RxBool boAuthenticated = false.obs;

  @override
  RxBool boExpired = false.obs;

  @override
  RxBool isAuthExpired = false.obs;

  @override
  RxBool isFullyAuthenticated = false.obs;

  @override
  RxBool mobileAuthenticated = false.obs;

  @override
  bool enableTruVideoSdk = false;

  @override
  GetStorage storage = GetStorage();

  @override
  void checkBackOfficeValidity() {}

  @override
  Future<void> setBackOfficeSuccess(String token) async {
    // Mock impl
  }

  @override
  void clearBackOfficeAuth() {}

  @override
  void clearMobileAuth() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthController controller;
  late TestLocalDatabase mockLocalDatabase;
  late TestApiService mockApiService;
  late TestConnectivityService mockConnectivityService;
  late TestHomeController mockHomeController;

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async => '/tmp',
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('PonnamKarthik/fluttertoast'),
          (MethodCall methodCall) async => true,
        );
  });

  setUp(() {
    Get.testMode = true;
    mockLocalDatabase = TestLocalDatabase();
    mockConnectivityService = TestConnectivityService();
    mockHomeController = TestHomeController();
    Get.put<HomeController>(mockHomeController);

    controller = AuthController();
    controller.localDatabase = mockLocalDatabase;
    controller.connectivityService = mockConnectivityService;
    controller.onInit(); // Initialize controllers
    // ApiService injected per test if needed
  });

  tearDown(() {
    Get.reset();
  });

  group('AuthController Initialization', () {
    test('should initialize with empty credentials list', () {
      expect(controller.savedCredentials, isEmpty);
    });

    test('should fetch credentials on init', () {
      mockLocalDatabase.mockCredentials = [
        CredentialsModel(
          id: '1',
          apiKey: 'key',
          secret: 'secret',
          externalId: 'ext',
        ),
      ];
      controller
          .onInit(); // Manually calling onInit since we just instantiated it
      expect(controller.savedCredentials.length, 1);
    });
  });

  group('backOfficeAuthentication', () {
    test('should fail if fields are empty', () {
      controller.boApiKeyController.text = '';
      controller.boSecretKeyController.text = '';

      controller.backOfficeAuthentication();

      expect(controller.boLoading.value, false);
    });

    test('should succeed with valid response', () async {
      mockApiService = TestApiService(
        postMock: (path, data) async => {'accessToken': 'valid_token'},
      );
      controller.apiService = mockApiService;

      controller.boApiKeyController.text = 'key';
      controller.boSecretKeyController.text = 'secret';
      controller.boExternalIdController.text = 'ext';

      controller.backOfficeAuthentication();

      await Future.delayed(Duration(milliseconds: 100)); // Wait for async

      expect(controller.boLoading.value, false);
      expect(controller.backOfficeAuthResponse.value, isNotNull);
      expect(
        controller.backOfficeAuthResponse.value!['accessToken'],
        'valid_token',
      );
    });

    test('should handle API error', () async {
      mockApiService = TestApiService(postMock: (path, data) async => null);
      controller.apiService = mockApiService;

      controller.boApiKeyController.text = 'key';
      controller.boSecretKeyController.text = 'secret';

      controller.backOfficeAuthentication();

      await Future.delayed(Duration(milliseconds: 100));

      expect(controller.boLoading.value, false);
      expect(controller.backOfficeAuthResponse.value, isNull);
    });
  });

  group('Credentials Management', () {
    test('saveUpdateCredentials should save new credentials', () async {
      controller.saveUpdateCredentials(
        false,
        'key',
        'secret',
        'ext',
        title: 'Test',
      );

      await Future.delayed(Duration(milliseconds: 50));

      expect(mockLocalDatabase.mockCredentials.length, 1);
      expect(mockLocalDatabase.mockCredentials.first.apiKey, 'key');
    });

    test('saveUpdateCredentials should update existing credentials', () async {
      // Setup existing
      final cred = CredentialsModel(
        id: '1',
        apiKey: 'old',
        secret: 'old',
        externalId: 'old',
      );
      await mockLocalDatabase.saveNewCredentials(cred);

      controller.saveUpdateCredentials(true, 'new', 'new', 'new', id: '1');

      await Future.delayed(Duration(milliseconds: 50));

      expect(mockLocalDatabase.mockCredentials.length, 1);
      expect(mockLocalDatabase.mockCredentials.first.apiKey, 'new');
    });

    test('deleteCredentials should remove credentials', () async {
      final cred = CredentialsModel(
        id: '1',
        apiKey: 'key',
        secret: 'secret',
        externalId: 'ext',
      );
      await mockLocalDatabase.saveNewCredentials(cred);

      controller.deleteCredentials('1');

      await Future.delayed(Duration(milliseconds: 50));

      expect(mockLocalDatabase.mockCredentials, isEmpty);
    });
  });
}
