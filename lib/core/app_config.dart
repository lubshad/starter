late final AppConfig appConfig;
abstract class AppConfig {
  String get refundPolicy;

  String get termsAndConditions;

  String get privacyPolicy;

  String get domain;
  String get slugUrl;
  String get baseUrl => domain + slugUrl;
}