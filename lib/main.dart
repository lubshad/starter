import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'core/app_route.dart';
import 'theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'utils/shared_preferences_utils.dart';

final navigatorKey = GlobalKey<NavigatorState>();

mainCommon() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SharedPreferencesService.i.initialize();

    FirebaseAuth.instance.userChanges().listen((user) async {
    if (user == null) {
      SharedPreferencesService.i.clearValue();
    } else {
      SharedPreferencesService.i.setValue(
          value:
              await FirebaseAuth.instance.currentUser?.getIdToken(true) ?? "");
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    FirebaseAnalyticsObserver observer =
        FirebaseAnalyticsObserver(analytics: analytics);
    return MaterialApp(
      navigatorObservers: [observer],
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRoute.onGenerateRoute,
      onGenerateInitialRoutes: AppRoute.onGenerateInitialRoute,
      theme: themeData,
    );
  }
}
