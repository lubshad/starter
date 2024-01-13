import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../gen/assets.gen.dart';
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
            Align(
              alignment: Alignment.centerLeft,
              child: SvgPicture.asset(
                Assets.svgs.appIcon,
              ),
            ),
            const Spacer(),
            FadeScaleTransition(
              animation: controller,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    Assets.svgs.vector1,
                  ),
                  SvgPicture.asset(
                    Assets.svgs.vector2,
                  ),
                  SvgPicture.asset(
                    Assets.svgs.cycleMoon,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              'Your extreme Classroom extension',
              style: context.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Text(
              "Create  an account or login to enjoy a new learning experience",
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
