import 'package:doctro/core/constants/common_function.dart';
import 'package:dio/dio.dart' hide Headers;

class ServerError implements Exception {
  int? _errorCode;
  String _errorMessage = "";

  ServerError.withError({error}) {
    _handleError(error);
  }

  getErrorCode() {
    return _errorCode;
  }

  getErrorMessage() {
    return _errorMessage;
  }

  void _handleError(DioException error) {
    final data = error.response?.data;
    String message = "";

    if (error.response?.statusCode == 401) {
      message = data?['msg']?.toString() ??
          data?['message']?.toString() ??
          "Unauthorized";
      if (message.toLowerCase().contains("unauthorized")) {
        message = "Session expired. Please log in again.";
      }
    } else if (data?['error'] != null) {
      message = '${data['error']}';
    } else if (error.type == DioExceptionType.badResponse) {
      if (data?['msg'] != null) {
        message = data['msg'].toString();
      } else if (data?['message'] != null) {
        message = data['message'].toString();
      }
    } else if (error.type == DioExceptionType.unknown) {
      message = data?['msg']?.toString() ?? "Unexpected error occurred";
    } else if (error.type == DioExceptionType.cancel) {
      message = 'Request was cancelled';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'Connection failed. Please check internet connection';
    } else if (error.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timeout';
    } else if (error.type == DioExceptionType.badCertificate) {
      message = data?['msg']?.toString() ?? 'Bad certificate';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      message = 'Receive timeout in connection';
    } else if (error.type == DioExceptionType.sendTimeout) {
      message = 'Receive timeout in send request';
    } else if (data?['errors'] is Map) {
      final errors = data!['errors'] as Map;
      for (final field in [
        'name',
        'phone',
        'phone_code',
        'password',
        'email',
        'description',
        'old_password',
        'password_confirmation',
      ]) {
        if (errors[field] != null) {
          message = errors[field][0].toString();
          break;
        }
      }
    }

    if (message.isEmpty) {
      message = error.message?.toString() ?? "Something went wrong. Please try again.";
    }

    _errorCode = error.response?.statusCode;
    _errorMessage = message;
    CommonFunction.toastMessage(message);
  }
}
