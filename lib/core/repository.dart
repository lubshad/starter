import 'package:dio/dio.dart';
import '../main.dart';
import 'app_config.dart';
import 'interceptors.dart';

class DataRepository {
  final Dio _client = Dio(BaseOptions(
      baseUrl: AppConfig.of(navigatorKey.currentContext!).baseUrl,
      contentType: "application/json"));

  static DataRepository get i => _instance;
  static final DataRepository _instance = DataRepository._private();

  DataRepository._private() {
    _client.interceptors.add(LoggingInterceptor());
  }
}
