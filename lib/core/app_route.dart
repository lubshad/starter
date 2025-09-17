import 'package:animations/animations.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../features/authentication/phone_auth/phone_auth_screen.dart';
import '../features/authentication/social_authentication/otp_validation_screen.dart';
import '../features/authentication/social_authentication/social_authentication_screen.dart';
import '../features/chat/agora_rtm_service.dart';
import '../features/chat/chats.dart';
import '../features/home_screen/home_screen.dart';
import '../features/navigation/navigation_screen.dart';
import '../features/splash_screen/splash_screen.dart';
import '../mixins/force_update.dart';
import 'logger.dart';

class AppRoute {
  static List<Route<dynamic>> onGenerateInitialRoute(String path) {
    Uri uri = Uri.parse(path);
    logInfo(uri);
    return [
      pageRoute(
        const RouteSettings(name: SplashScreen.path),
        const SplashScreen(),
      ),
    ];
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    logInfo(settings.name);
    Uri uri = Uri.parse(settings.name ?? "");
    final Widget screen;


    final agoraRoute = AgoraRTMService.i.handleAgoraRoutes(settings);
    if (agoraRoute != null) {
      return agoraRoute;
    }

    switch (uri.path) {
      case ChatPage.path:
        screen = ChatPage();
        break;
      case SplashScreen.path:
        screen = const SplashScreen();
        break;
      case SocialAuthenticationScreen.path:
        screen = const SocialAuthenticationScreen();
        break;
      case HomeScreen.path:
        screen = const HomeScreen();
        break;
      case PhoneVerification.path:
        screen = const PhoneVerification();
        break;
      case NavigationScreen.path:
        screen = const NavigationScreen();
        break;
      case UnavailabilityScreen.path:
        screen = const UnavailabilityScreen();
        break;
      case OTPScreen.path:
        Map data = settings.arguments as Map;
        screen = OTPScreen(
          domainUrl: data["domain_url"],
          username: data["username"],
          password: data["password"],
        );
        break;
      default:
        return null;
    }
    return pageRoute(settings, screen);
  }
}

Route<T> pageRoute<T>(
  RouteSettings settings,
  Widget screen, {
  bool animate = true,
}) {
  if (!animate) {
    return PageRouteBuilder(
      settings: settings,
      opaque: true,
      pageBuilder: (context, animation, secondaryAnimation) => screen,
    );
  }
  return MaterialPageRoute(settings: settings, builder: (context) => screen);
}

PageRouteBuilder downToTop(RouteSettings settings, Widget screen) {
  return PageRouteBuilder(
    transitionDuration: animationDurationLarge,
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => screen,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = const Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.fastOutSlowIn;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}

PageRouteBuilder fadeScale(RouteSettings settings, Widget screen) {
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => screen,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeScaleTransition(animation: animation, child: child);
    },
  );
}

Future<T?> navigate<T extends Object?>(
  BuildContext context,
  String routeName, {
  Object? arguments,
  bool duplicate = false,
  bool replace = false,
}) async {
  final currentRoute = ModalRoute.of(context)?.settings.name;
  if (routeName == currentRoute && !duplicate) return null;
  if (replace) {
    return await Navigator.of(context).pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  } else {
    return await Navigator.of(
      context,
    ).pushNamed<T>(routeName, arguments: arguments);
  }
}
