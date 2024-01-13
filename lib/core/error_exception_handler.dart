// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dio/dio.dart';

class CustomException implements Exception {
  final dynamic message;
  CustomException(this.message);
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
            exception = CustomException(dioException.response?.data);
            break;
        }
      default:
        exception = CustomException(exception);
    }
    return exception;
  }
}
