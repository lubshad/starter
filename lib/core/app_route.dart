import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../features/authentication/landing_screen/landing_screen.dart';
import '../features/authentication/phone_auth/phone_auth_screen.dart';
import '../features/screens/home_screen/home_screen.dart';
import 'logger.dart';

class AppRoute {
  static List<Route<dynamic>> onGenerateInitialRoute(String path) {
    Uri uri = Uri.parse(path);
    logInfo(uri);
    if (FirebaseAuth.instance.currentUser == null) {
      return [
        pageRoute(
            const RouteSettings(name: LandingPage.path), const LandingPage())
      ];
    }
    return [
      pageRoute(const RouteSettings(name: HomeScreen.path), const HomeScreen())
    ];
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    logInfo(settings.name);
    Uri uri = Uri.parse(settings.name ?? "");
    switch (uri.path) {
      case HomeScreen.path:
        return pageRoute(settings, const HomeScreen());
      case PhoneVerification.path:
        return pageRoute(settings, const PhoneVerification());
      default:
        return pageRoute(settings, const Scaffold());
    }
  }

  static MaterialPageRoute<dynamic> pageRoute(
      RouteSettings settings, Widget screen) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => screen,
    );
  }
}
