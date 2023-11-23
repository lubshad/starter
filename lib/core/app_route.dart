import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
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

  static MaterialPageRoute<T> pageRoute<T>(
      RouteSettings settings, Widget screen) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => screen,
    );
  }

  static PageRouteBuilder downToTop(RouteSettings settings, Widget screen) {
    return PageRouteBuilder(
      transitionDuration: animationDurationLarge,
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.fastOutSlowIn;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  static PageRouteBuilder fadeScale(RouteSettings settings, Widget screen) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeScaleTransition(
          animation: animation,
          child: child,
        );
      },
    );
  }
}
