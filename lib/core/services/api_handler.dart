import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:media_upload_sample_app/features/common/widgets/error_widget.dart';

class ApiHandler {
  String? _extractServerErrorMessage(dynamic responseData) {
    if (responseData is Map) {
      final detail = responseData['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail.trim();
      }

      final message = responseData['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }

    if (responseData is String && responseData.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(responseData);
        if (decoded is Map) {
          final detail = decoded['detail'];
          if (detail is String && detail.trim().isNotEmpty) {
            return detail.trim();
          }

          final message = decoded['message'];
          if (message is String && message.trim().isNotEmpty) {
            return message.trim();
          }
        }
      } catch (_) {
        return responseData.trim();
      }
    }

    return null;
  }

  /// Get relevant messages for dio exceptions.
  String getExceptionMessage(DioException exception) {
    final serverErrorMessage = _extractServerErrorMessage(
      exception.response?.data,
    );
    if (serverErrorMessage != null) {
      return serverErrorMessage;
    }

    switch (exception.type) {
      case DioExceptionType.badResponse:
        return 'Bad Response from server, Try again later.';
      case DioExceptionType.connectionTimeout:
        return 'Connection Timeout, Check your Internet Connection';
      case DioExceptionType.connectionError:
        return 'Network Error, Check your Internet Connection';
      case DioExceptionType.receiveTimeout:
        return 'Connection Timeout, Check your Internet Connection';
      case DioExceptionType.sendTimeout:
        return 'Connection Timeout, Check your Internet Connection';
      case DioExceptionType.cancel:
        return 'Request cancel while communicating to server';
      default:
        return 'Something went wrong, Try again later.';
    }
  }

  void errorSnackBar(String error) {
    Get.dialog(ErrorDialog(title: 'Error', subTitle: error));
  }
}
