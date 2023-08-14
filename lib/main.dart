import 'package:flutter/material.dart';

import 'core/app_route.dart';
import 'core/theme.dart';
import 'utils/snackbar_utils.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengetKey,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRoute.onGenerateRoute,
      onGenerateInitialRoutes: AppRoute.onGenerateInitialRoute,
      theme: themeData,
    );
  }
}
