late final AppConfig appConfig;
abstract class AppConfig {
  String get domain;
  String get slugUrl;
  String get baseUrl => domain + slugUrl;
}