late final AppConfig appConfig;

abstract class AppConfig {
  String get scheme;
  String get port;
  String get refundPolicy;

  String get termsAndConditions;

  String get privacyPolicy;

  String get domain;
  String get slugUrl;
  String get baseUrl => "$scheme://$domain:$port$slugUrl";
}
