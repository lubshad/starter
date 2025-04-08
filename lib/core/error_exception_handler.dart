// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

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

const cannotReachServer = "Server cannot be reached!";
const noNetwork = "Please check your network connection!";
const somethingWentWrong = "Something went wrong!";
const invalidUrl = "Please enter a valid url!";
mixin ErrorExceptionHandler {
  handleError(exception) {
    switch (exception.runtimeType) {
      case const (DioException):
        String message = somethingWentWrong;
        final dioException = exception as DioException;
        switch (dioException.type) {
          case DioExceptionType.connectionError:
            if (dioException.error is SocketException) {
              if ([61, 64, 8].contains(
                  (dioException.error as SocketException).osError?.errorCode)) {
                message = cannotReachServer;
              } else if ([101].contains(
                  (dioException.error as SocketException).osError?.errorCode)) {
                message = noNetwork;
              }
            }

            exception = CustomException(message);
            break;
          case DioExceptionType.connectionTimeout:
            message = cannotReachServer;
            exception = CustomException(message);
            break;
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.cancel:
          case DioExceptionType.unknown:
            if (dioException.error is HandshakeException) {
              exception = CustomException(
                  (dioException.error as HandshakeException).message);
            }
            break;
          case DioExceptionType.badCertificate:
            break;
          case DioExceptionType.badResponse:
            var data = dioException.response?.data;
            if (data is Map) {
              message = data["message"] ?? data["error"]["message"] ?? "";
            } else {
              message = invalidUrl;
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
