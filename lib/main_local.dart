import 'package:flutter/material.dart';

import 'core/app_config.dart';
import 'main.dart';

class AppConfigLocal extends AppConfig {
  @override
  // TODO: implement domain
  String get domain => throw UnimplementedError();

  @override
  // TODO: implement slugUrl
  String get slugUrl => throw UnimplementedError();
  
  @override
  // TODO: implement privacyPolicy
  String get privacyPolicy => throw UnimplementedError();
  
  @override
  // TODO: implement refundPolicy
  String get refundPolicy => throw UnimplementedError();
  
  @override
  // TODO: implement termsAndConditions
  String get termsAndConditions => throw UnimplementedError();
  
  @override
  // TODO: implement port
  String get port => throw UnimplementedError();
  
  @override
  // TODO: implement scheme
  String get scheme => throw UnimplementedError();
}

void main() async {
  await mainCommon();
  appConfig = AppConfigLocal();
  runApp(const MyApp());
}
