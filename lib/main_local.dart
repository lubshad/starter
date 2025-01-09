import 'package:flutter/material.dart';

import 'core/app_config.dart';
import 'main.dart';

class AppConfigLocal extends AppConfig {
  @override
  String get domain => throw UnimplementedError();

  @override
  String get slugUrl => throw UnimplementedError();

  @override
  String get port => throw UnimplementedError();
  
  @override
  String get scheme => throw UnimplementedError();
  
  @override
  ENV get env => ENV.local;


  @override
  String get password => "password";
  
  @override
  String get username => "username";
}

void main() async {
  await mainCommon();
  appConfig = AppConfigLocal();
  runApp(const MyApp());
}
