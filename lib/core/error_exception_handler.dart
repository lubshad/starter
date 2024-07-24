// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dio/dio.dart';

class CustomException implements Exception {
  final dynamic message;
  final int? statusCode;
  CustomException(
    this.message, {
    this.statusCode,
  });
  @override
  String toString() {
    return message;
  }
}

mixin ErrorExceptionHandler {
  handleError(exception) {
    switch (exception.runtimeType) {
      case const (DioException):
        final dioException = exception as DioException;
        switch (dioException.type) {
          case DioExceptionType.connectionError:
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.cancel:
          case DioExceptionType.unknown:
          case DioExceptionType.badCertificate:
            break;
          case DioExceptionType.badResponse:
            var data = dioException.response?.data;
            final String message;
            if (data is Map) {
              message = data["message"] ?? data["error"]["message"] ?? "";
            } else {
              message = data.toString();
            }
            exception = CustomException(
              statusCode: dioException.response?.statusCode,
              message,
            );
            break;
        }
      default:
        exception = CustomException(exception.toString());
    }
    return exception;
  }
}
