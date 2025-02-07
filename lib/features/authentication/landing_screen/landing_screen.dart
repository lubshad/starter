import 'package:flutter/material.dart';
import '../../../widgets/loading_button.dart';
import '../phone_auth/phone_auth_screen.dart';
import '../../../exporter.dart';
import 'widgets/landing_screen_item.dart';

class LandingPage extends StatefulWidget {
  static const String path = "/landing-page";

  const LandingPage({
    super.key,
  });

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  void _goToNextPage() {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(
      children: [
        const Spacer(),
        AspectRatio(
          aspectRatio: 0.9,
          child: PageView(
            controller: _pageController,
            children: <Widget>[
              LandingScreenItem(
                description:
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt dolore magna aliqua",
                title: "Welcome to App",
                image: Assets.svgs.landingOne,
              ),
              LandingScreenItem(
                description:
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt dolore magna aliqua",
                title: "Welcome to App",
                image: Assets.svgs.landingTwo,
              ),
              LandingScreenItem(
                description:
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt dolore magna aliqua",
                title: "Welcome to App",
                image: Assets.svgs.landingThree,
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: paddingSmall),
              height: padding,
              width: _currentPage == index ? 24.0 : 8.0,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? const Color(0xff2ECC71)
                    : const Color(0xffD9D9D9),
                borderRadius: BorderRadius.circular(12.0),
              ),
            );
          }),
        ),
        const Spacer(
          flex: 3,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: paddingXXL),
          child: LoadingButton(
            // padding: const EdgeInsets.symmetric(horizontal: paddingLarge),
            onPressed: () {
              Navigator.pushNamed(context, PhoneVerification.path);
            },
            text: ('Get Started'),
            buttonLoading: false,
          ),
        ),
        gap,
        Opacity(
          opacity: _currentPage < 2 ? 1 : 0,
          child: TextButton(
            onPressed: _goToNextPage,
            child: const Text(
              'Next',
            ),
          ),
        ),
        gapXL
      ],
    )));
  }
}
