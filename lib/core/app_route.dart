import 'package:flutter/material.dart';

import '../screens/home_screen/home_screen.dart';
import 'logger.dart';

class AppRoute {
  static List<Route<dynamic>> onGenerateInitialRoute(String path) {
    Uri uri = Uri.parse(path);
    return [pageRoute(RouteSettings(name: uri.path), const HomeScreen())];
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    logInfo(settings.name);
    Uri uri = Uri.parse(settings.name ?? "");
    switch (uri.path) {
      case HomeScreen.path:
        return pageRoute(settings, const HomeScreen());
      default:
    }
    return null;
  }

  static MaterialPageRoute<dynamic> pageRoute(
      RouteSettings settings, Widget screen) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => screen,
    );
  }
}
