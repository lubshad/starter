import 'package:flutter/material.dart';

import 'core/app_config.dart';
import 'main.dart';

class AppConfigDev extends AppConfig {
  @override
  // TODO: implement domain
  String get domain => throw UnimplementedError();

  @override
  // TODO: implement slugUrl
  String get slugUrl => throw UnimplementedError();
}

void main() async {
  await mainCommon();
  appConfig = AppConfigDev();
  runApp(const MyApp());
}
