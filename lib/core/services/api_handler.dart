import 'package:dio/dio.dart';
import 'package:media_upload_sample_app/core/utils/utils.dart';

class ApiHandler {
  /// Get relevant messages for dio exceptions.
  String getExceptionMessage(DioException exception) {
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
    Utils.showToast(error);
  }
}
