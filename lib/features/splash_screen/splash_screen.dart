// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/app_route.dart';
import '../../exporter.dart';
import '../../services/shared_preferences_services.dart';
import '../../widgets/error_widget_with_retry.dart';
import '../../widgets/network_resource.dart';
import '../authentication/landing_screen/landing_screen.dart';
import '../navigation/navigation_screen.dart';
import '../profile_screen/common_controller.dart';
import 'models/registration_state.dart';

class SplashScreen extends StatefulWidget {
  static const String path = "/splash-screen";

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void>? future;

  @override
  void initState() {
    super.initState();
    fetchRegistrationState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NetworkResource(
        future,
        error: (error) => ErrorWidgetWithRetry(
          exception: error,
          retry: fetchRegistrationState,
        ),
        success: (data) => const SizedBox(),
        loading: Center(
          child:
              Container(
                    padding: const EdgeInsets.all(paddingLarge),
                    width: 140,
                    height: 140,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Placeholder(),
                  )
                  .animate()
                  .scaleXY(
                    begin: 1.5,
                    end: 1,
                    duration: const Duration(seconds: 1),
                    curve: Curves.fastOutSlowIn,
                  )
                  .then()
                  .scaleXY(
                    begin: 1,
                    end: 10,
                    duration: const Duration(seconds: 2),
                    curve: Curves.fastOutSlowIn,
                  )
                  .fadeOut(),
        ),
      ),
    );
  }

  void fetchRegistrationState() async {
    final isLoggedIn = (await SharedPreferencesService.i.token) != "";
    if (isLoggedIn) {
      CommonController.i.init();
    }
    setState(() {
      future =
          Future.wait([
            // DataRepository.i.fetchRegistrationState(),
            Future.delayed(const Duration(seconds: 3)),
          ]).then((value) async {
            // throw DioException(requestOptions: RequestOptions());
            RegistrationState state = RegistrationState.completed;
            // RegistrationState.fromString(value.first.data["state"]);
            switch (state) {
              case RegistrationState.basicDetails:
              // Navigator.pushNamedAndRemoveUntil(
              //     context, BasicDetailsForm.path, (route) => false);
              // break;
              case RegistrationState.programSelection:
              // Navigator.pushNamedAndRemoveUntil(
              //     context, ProgramSelectionForm.path, (route) => false);
              // break;
              case RegistrationState.completed:
                if (isLoggedIn) {
                  navigate(context, NavigationScreen.path, replace: true);
                } else {
                  navigate(context, LandingPage.path, replace: true);
                }
                break;
            }
          });
    });
  }
}
