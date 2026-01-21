import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:media_upload_sample_app/core/resourses/endpoints.dart';
import 'package:media_upload_sample_app/core/services/api_handler.dart';

class ApiService {
  factory ApiService() => _instance;

  ApiService._internal() {
    dio = createDio(baseUrl: Endpoints.loginRCBaseUrl);
  }

  static final ApiService _instance = ApiService._internal();
  late Dio dio;

  /// Helper to create a Dio instance with logging and standard interceptors
  Dio createDio({String? baseUrl, String? token, bool logBody = true}) {
    final newDio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? Endpoints.loginRCBaseUrl,
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      ),
    );

    // Add logging interceptor for debugging
    newDio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: logBody,
        responseHeader: true,
        responseBody: logBody,
        error: true,
        // logPrint: (obj) => debugPrint('API LOG: $obj'),
      ),
    );

    newDio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException exception, handler) {
          final err = ApiHandler().getExceptionMessage(exception);
          ApiHandler().errorSnackBar(err);
          handler.next(exception);
        },
      ),
    );

    return newDio;
  }

  /// Reusable function for Get API.
  Future<T?> get<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? token,
    String? baseUrl,
  }) async {
    try {
      final dioInstance = (baseUrl != null || token != null)
          ? createDio(baseUrl: baseUrl, token: token)
          : dio;

      Response res = await dioInstance.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      if (res.statusCode != null &&
          res.statusCode! >= 200 &&
          res.statusCode! < 300) {
        return res.data;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  /// Reusable function for Post API.
  Future<T?> post<T>({
    required String path,
    required dynamic data,
    Options? options,
    String? token,
    String? baseUrl,
  }) async {
    try {
      final dioInstance = (baseUrl != null || token != null)
          ? createDio(baseUrl: baseUrl, token: token)
          : dio;

      Response res = await dioInstance.post(path, data: data, options: options);

      if (res.statusCode != null &&
          res.statusCode! >= 200 &&
          res.statusCode! < 300) {
        return res.data;
      } else {
        return null;
      }
    } on DioException catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  /// Reusable function for Put API.
  Future<T?> put<T>({
    required String path,
    required dynamic data,
    Options? options,
    String? token,
    String? baseUrl,
  }) async {
    try {
      final dioInstance = (baseUrl != null || token != null)
          ? createDio(baseUrl: baseUrl, token: token)
          : dio;

      Response res = await dioInstance.put(path, data: data, options: options);
      if (res.statusCode != null &&
          res.statusCode! >= 200 &&
          res.statusCode! < 300) {
        return res.data;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}
