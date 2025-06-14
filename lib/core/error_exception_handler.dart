// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../exporter.dart';

enum CustomExceptionType {
  cannotReachServer,
  noNetwork,
  somethingWentWrong,
  invalidUrl,
  internalServerError;

  @override
  String toString() {
    return text;
  }

  String get text {
    switch (this) {
      case CustomExceptionType.cannotReachServer:
        return "Server cannot be reached!";
      case CustomExceptionType.noNetwork:
        return "Please check your network connection!";
      case CustomExceptionType.somethingWentWrong:
        return "Something went wrong!";
      case CustomExceptionType.invalidUrl:
        return "Please enter a valid url";
      case CustomExceptionType.internalServerError:
        return "Internal server error!";
    }
  }

  Widget get showErrorWidget {
    switch (this) {
      case CustomExceptionType.cannotReachServer:
        return SvgPicture.asset(Assets.svgs.serverError);
      case CustomExceptionType.noNetwork:
        return SvgPicture.asset(Assets.svgs.noNetwork);
      case CustomExceptionType.somethingWentWrong:
        return SvgPicture.asset(Assets.svgs.somethingWrong);
      case CustomExceptionType.invalidUrl:
        return SvgPicture.asset(Assets.svgs.invalidUrl);
      case CustomExceptionType.internalServerError:
        return SvgPicture.asset(Assets.svgs.internalError);
    }
  }
}

class CustomException implements Exception {
  final dynamic message;
  final int? statusCode;
  CustomException(
    this.message, {
    this.statusCode,
  });
  @override
  String toString() {
    return message.toString();
  }
}

mixin ErrorExceptionHandler {
  handleError(exception) {
    switch (exception.runtimeType) {
      case const (DioException):
        dynamic message = CustomExceptionType.somethingWentWrong;
        final dioException = exception as DioException;
        switch (dioException.type) {
          case DioExceptionType.connectionError:
            if (dioException.error is SocketException) {
              if ([61, 64, 8].contains(
                  (dioException.error as SocketException).osError?.errorCode)) {
                message = CustomExceptionType.cannotReachServer;
              } else if ([101].contains(
                  (dioException.error as SocketException).osError?.errorCode)) {
                message = CustomExceptionType.noNetwork;
              }
            }

            exception = CustomException(message);
            break;
          case DioExceptionType.connectionTimeout:
            message = CustomExceptionType.somethingWentWrong;
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
            if (dioException.response?.statusCode == 500) {
              message = CustomExceptionType.invalidUrl;
            } else if (data is Map) {
              message = data["message"] ?? data["error"]["message"] ?? "";
            } else {
              message = CustomExceptionType.internalServerError;
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
