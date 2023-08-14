
import 'package:dio/dio.dart';

import 'logger.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
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
