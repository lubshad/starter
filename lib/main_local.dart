import 'package:flutter/material.dart';

import 'core/app_config.dart';
import 'main.dart';

class AppConfigLocal extends AppConfig {
  @override
  String get domain => "domain";

  @override
  String get slugUrl => "/api/";

  @override
  String get port => "8000";

  @override
  String get scheme => "http";

  @override
  ENV get env => ENV.local;

  @override
  String get password => "password";

  @override
  String get username => "username";
  
  @override
  String get googleMapsApiKey => "AIzaSyBwAIsJa57pOEsDY9fBrtSODwaxuTksaDQ";
}

void main() async {
  appConfig = AppConfigLocal();
  await mainCommon();
  runApp(const MyApp());
}
