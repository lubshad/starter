import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../exporter.dart';
import '../services/shared_preferences_services.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (kDebugMode) await delayed();
    logInfo('--> ${options.method} ${options.uri}');
    logInfo('Headers:');
    options.headers.forEach((key, value) => logInfo('$key: $value'));
    logInfo('Data:');
    logInfo(options.data);
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logSuccess('<-- ${response.statusCode} ${response.requestOptions.uri}');
    logSuccess('Headers:');
    response.headers.forEach((key, value) => logSuccess('$key: $value'));
    logSuccess('Response Data:');
    logSuccess(response.data);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logError('<-- Error -->');
    logError('Request: ${err.requestOptions.method} ${err.requestOptions.uri}');
    logError('Response: ${err.response?.statusCode}');
    logError('Message: ${err.message}');
    logError('Error: ${err.error}');
    super.onError(err, handler);
  }
}

class AuthenticationInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    String token = SharedPreferencesService.i.getValue();
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      if (decodedToken.containsKey('exp')) {
        int expirationTimestamp = decodedToken['exp'];
        int currentTimestamp =
            DateTime.now().millisecondsSinceEpoch ~/ 1000; // Convert to seconds

        if (expirationTimestamp >= currentTimestamp) {
          logInfo("Token is still valid.");
        } else {
          logInfo("Token has expired.");
          // You might want to refresh the token here
          token =
              await FirebaseAuth.instance.currentUser?.getIdToken(true) ?? "";
          if (token != "") {
            SharedPreferencesService.i.setValue(value: token);
          }
        }
      } else {
        logInfo("Token does not have an expiration time.");
      }

      options.headers.addAll({"Authorization": token});
    } catch (e) {
      logInfo(e.toString());
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    switch (response.statusCode) {
      case 401:
        // FirebaseAuth.instance.signOut();
        break;
      default:
    }
    super.onResponse(response, handler);
  }
}
