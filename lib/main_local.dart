import 'package:flutter/material.dart';

import 'core/app_config.dart';
import 'main.dart';

void main() async {
  await mainCommon();
  runApp(const AppConfig(
      domain: 'http://0.0.0.0:8000',
      slugUrl: '/api/ai-assist/',
      child: MyApp()));
}
