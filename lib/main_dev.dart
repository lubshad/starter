
import 'package:flutter/material.dart';

import 'core/app_config.dart';
import 'main.dart';

void main() async {
  await mainCommon();
  runApp(const AppConfig(
      domain: 'http://dev.clezz.in',
      slugUrl: '/api/ai-assist/',
      child: MyApp()));
}
