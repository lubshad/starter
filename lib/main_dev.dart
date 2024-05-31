import 'package:flutter/material.dart';

import 'core/app_config.dart';
import 'main.dart';

class AppConfigDev extends AppConfig {
  @override
  String get domain => "159.89.100.251";

  @override
  String get slugUrl => "/employee/";

  @override
  String get privacyPolicy => throw UnimplementedError();

  @override
  String get refundPolicy => throw UnimplementedError();

  @override
  String get termsAndConditions => throw UnimplementedError();

  @override
  String get port => "8010";

  @override
  String get scheme => "http";
}

void main() async {
  await mainCommon();
  appConfig = AppConfigDev();
  runApp(const MyApp());
}
