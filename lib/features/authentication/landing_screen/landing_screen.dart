import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import '../../../widgets/loading_button.dart';
import '../phone_auth/phone_auth_screen.dart';
import '../../../exporter.dart';

class LandingPage extends StatefulWidget {
  static const String path = "/landing-page";

  const LandingPage({
    super.key,
  });

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: animationDuration);

    controller.drive(CurveTween(curve: Curves.fastOutSlowIn));
    controller.forward();
  }

  late AnimationController controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                  width: 100,
                  child: AspectRatio(aspectRatio: 3, child: Placeholder())),
            ),
            const Spacer(),
            FadeScaleTransition(
              animation: controller,
              child: const SizedBox(
                  width: 200,
                  child: AspectRatio(aspectRatio: 1, child: Placeholder())),
            ),
            gapLarge,
            Text(
              'Your app description',
              style: context.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Text(
              "Create  an account or login",
              style: context.labelLarge,
              textAlign: TextAlign.center,
            ),
            gapLarge,
            LoadingButton(
              onPressed: () {
                Navigator.pushNamed(context, PhoneVerification.path);
              },
              text: ('Get Started'),
              isLoading: false,
            ),
          ],
        ),
      ),
    ));
  }
}
