// ignore_for_file: depend_on_referenced_packages

import 'package:agora_chat_uikit/chat_uikit.dart';
import 'package:agora_chat_uikit/chat_uikit_localizations.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_in_app_pip/pip_material_app.dart';
import 'package:flutter_in_app_pip/pip_params.dart';
import 'package:flutter_in_app_pip/pip_view_corner.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/app_route.dart';
import 'core/repository.dart';
import 'features/chat/agora_rtm_service.dart';
import 'features/chat/user_listing.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'firebase_options.dart';
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
  await AgoraRTMService.i.initSdk(agoraConfig);
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

  ChatUIKitLocalizations chatLocalizations = ChatUIKitLocalizations();

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  late FirebaseAnalyticsObserver observer;
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, child) {
        return ToastificationWrapper(
          child: PiPMaterialApp(
            pipParams: PiPParams(
              pipWindowHeight: (150 / (120 / 180)).h,
              pipWindowWidth: 150.h,
              initialCorner: PIPViewCorner.topRight,
            ),
            localizationsDelegates: [
              CountryLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              ...chatLocalizations.localizationsDelegates,
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
