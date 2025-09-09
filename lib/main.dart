// ignore_for_file: depend_on_referenced_packages

import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:starter/core/app_route.dart';
import 'package:starter/core/repository.dart';
import 'package:starter/firebase_options.dart';
import 'features/chat/user_listing.dart';
import 'services/size_utils.dart';
import 'theme/theme.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
import 'services/shared_preferences_services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:toastification/toastification.dart';

final navigatorKey = GlobalKey<NavigatorState>();

// ignore: strict_top_level_inference
mainCommon() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SharedPreferencesService.i.initialize();
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  // FirebaseAuth.instance.userChanges().listen((user) async {
  //   if (user == null) {
  //     SharedPreferencesService.i.clear();
  //   } else {
  //     SharedPreferencesService.i.setValue(
  //         value:
  //             await FirebaseAuth.instance.currentUser?.getIdToken(true) ?? "");
  //   }
  // });

  // Setup crashletics
  if (!kIsWeb) {
    if (kDebugMode) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    } else {
      FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    }
  }
  await DataRepository.i.initialize();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    Animate.restartOnHotReload = true;
    Animate.defaultCurve = Curves.fastOutSlowIn;
    observer = FirebaseAnalyticsObserver(analytics: analytics);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setSystemOverlay();
    });
    super.initState();
  }

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  late FirebaseAnalyticsObserver observer;
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder:
          (
            BuildContext context,
            Orientation orientation,
            DeviceType deviceType,
          ) {
            return ToastificationWrapper(
              child: MaterialApp(
                localizationsDelegates: const [
                  CountryLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                navigatorObservers: [observer],
                navigatorKey: navigatorKey,
                debugShowCheckedModeBanner: false,
                onGenerateRoute: AppRoute.onGenerateRoute,
                // onGenerateInitialRoutes: AppRoute.onGenerateInitialRoute,
                theme: themeData,
                home: UserListingScreen(),
              ),
            );
          },
    );
  }
}
