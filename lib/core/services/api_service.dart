import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:media_upload_sample_app/core/resourses/endpoints.dart';
import 'package:media_upload_sample_app/core/services/api_handler.dart';

class ApiService {
  factory ApiService() => _instance;

  ApiService._internal() {
    final baseOptions = BaseOptions(baseUrl: Endpoints.baseUrl);
    dio = Dio(baseOptions);

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException exception, handler) {
          final err = ApiHandler().getExceptionMessage(exception);
          ApiHandler().errorSnackBar(err);
          handler.next(exception);
        },
      ),
    );
  }
  static final ApiService _instance = ApiService._internal();
  late Dio dio;

  /// Reusable function for Get API.
  /// Define return type during calling
  /// ```dart
  /// String? response = await ApiService().get<String>(path: 'Your Endpoint');
  /// ```
  Future<T?> get<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? token,
  }) async {
    try {
      Response res = await dio.get(
        path,
        queryParameters: queryParameters,
        options:
            options ?? Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (res.statusCode == 200) {
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
  /// Define return type during calling
  /// ```dart
  /// String? response = await ApiService().post<String>(path: 'Your Endpoint', data: {});
  /// ```
  Future<T?> post<T>({
    required String path,
    required dynamic data,
    Options? options,
    String? token,
  }) async {
    try {
      Response res = await dio.post(
        path,
        data: data,
        options:
            options ?? Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (res.statusCode == 200) {
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
  /// Define return type during calling
  /// ```dart
  /// String? response = await ApiService().put<String>(path: 'Your Endpoint', data: {});
  /// ```
  Future<T?> put<T>({
    required String path,
    required dynamic data,
    Options? options,
    String? token,
  }) async {
    try {
      Response res = await dio.put(
        path,
        data: data,
        options:
            options ?? Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (res.statusCode == 200) {
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
