// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:starter/features/home_screen/home_screen.dart';

import '../../../core/app_route.dart';

final homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: "home");
final settingsNavigationKey = GlobalKey<NavigatorState>(debugLabel: "settings");
final profileNavigationKey = GlobalKey<NavigatorState>(debugLabel: "profile");

enum Screens {
  // home,
  home,
  settings,
  profile;

  BuildContext get context {
    switch (this) {
      case Screens.home:
        return homeNavigatorKey.currentContext!;
      case Screens.settings:
        return settingsNavigationKey.currentContext!;
      case Screens.profile:
        return profileNavigationKey.currentContext!;
    }
  }

  Widget get bottomIcon {
    switch (this) {
      // case Screens.home:
      //   return SvgPicture.asset(Assets.svgs.homeIcon);
      case Screens.home:
        return const Icon(Icons.home);
      case Screens.settings:
        return const Icon(Icons.settings);
      case Screens.profile:
        return const Icon(Icons.person);
    }
  }

  GlobalKey get navigatorKey {
    switch (this) {
      // case Screens.home:
      //   return homeNavigatorKey;
      case Screens.home:
        return homeNavigatorKey;
      case Screens.settings:
        return settingsNavigationKey;
      case Screens.profile:
        return profileNavigationKey;
    }
  }

  String get initialRoute {
    switch (this) {
      // case Screens.home:
      //   return "";
      case Screens.home:
        return HomeScreen.path;
      case Screens.settings:
        return HomeScreen.path;
      case Screens.profile:
        return HomeScreen.path;
    }
  }

  Widget get activeIcon {
    switch (this) {
      // case Screens.home:
      //   return SvgPicture.asset(Assets.svgs.homeIcon, color: selectedItemColor);
      case Screens.home:
        return const Icon(Icons.home);
      case Screens.settings:
        return const Icon(Icons.settings);
      case Screens.profile:
        return const Icon(Icons.person);
    }
  }

  Widget get body {
    switch (this) {
      // case Screens.home:
      //   return const Center(
      //     child: Text("Home"),
      //   );
      case Screens.home:
        return Navigator(
          key: navigatorKey,
          onGenerateRoute: AppRoute.onGenerateRoute,
          initialRoute: initialRoute,
        );
      case Screens.settings:
        return Navigator(
          key: profileNavigationKey,
          onGenerateRoute: AppRoute.onGenerateRoute,
          initialRoute: initialRoute,
        );

      case Screens.profile:
        return const Center(
          child: Text("Profile"),
        );
    }
  }

  String get label {
    switch (this) {
      // case Screens.home:
      //   return "Home";
      case Screens.home:
        return "Home";
      case Screens.settings:
        return "Settings";
      case Screens.profile:
        return "Profile";
    }
  }

  popAll() {
    Navigator.popUntil(context, (route) => route.settings.name == initialRoute);
  }
}
