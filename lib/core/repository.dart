import 'package:dio/dio.dart';
import 'app_config.dart';
import 'interceptors.dart';

bool validateStatus(int? status) {
  List validStatusCodes = [
    304,
    200,
    201,
  ];
  return validStatusCodes.contains(status);
}

class DataRepository {
  final Dio _client = Dio(BaseOptions(
      validateStatus: validateStatus,
      baseUrl: appConfig.baseUrl,
      receiveDataWhenStatusError: true,
      contentType: "application/json"));

  static DataRepository get i => _instance;
  static final DataRepository _instance = DataRepository._private();

  DataRepository._private() {
    _client.interceptors.add(AuthenticationInterceptor());
    _client.interceptors.add(LoggingInterceptor());
  }
}
