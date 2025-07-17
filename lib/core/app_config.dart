import 'package:get/get.dart';

import '../main_local.dart';

late final AppConfig appConfig;

enum ENV {
  local,
  dev,
  prod;

  AppConfig get appConfig {
    switch (this) {
      case ENV.local:
        return AppConfigLocal();
      case ENV.dev:
        return AppConfigLocal();
      case ENV.prod:
        return AppConfigLocal();
    }
  }

  static ENV fromValue(dynamic value) {
    return ENV.values.firstWhereOrNull((element) => element.index == value) ??
        ENV.local;
  }
}

abstract class AppConfig {
  ENV get env;
  String get scheme;
  String get port;

  String get domain;
  String get slugUrl;
  String get username;
  String get password;
  String get baseUrl => "$scheme://$domain:$port$slugUrl";
  String get domainOnly => "$scheme://$domain:$port";
}
