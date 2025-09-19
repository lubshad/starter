import 'package:flutter/material.dart';
import '../../../core/app_route.dart';
import '../phone_auth/phone_auth_screen.dart';
import '../../../exporter.dart';
import 'widgets/landing_screen_item.dart';

class LandingPage extends StatefulWidget {
  static const String path = "/landing-page";

  const LandingPage({super.key});

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

  List<Color> get colors => _currentPage == 0
      ? [Color(0xff1A507C), Color(0xff92BEE3), Color(0xff1A507C)]
      : [Color(0xff0D2227), Color(0xff406E7C), Color(0xff0E2F38)];

  List<Widget> children = <Widget>[
    LandingScreenItem(
      description:
          "Skip the wait.\nBook dental appointments, consult top dentists online, and track your treatment — all from your mobile.",
      title: "Your Smile. Our Mission. Anytime, Anywhere.",
      image: Assets.pngs.landing1.keyName,
    ),
    LandingScreenItem(
      description:
          "Bringing expert dental care to your fingertips — trusted by thousands across Saudi Arabia.",
      title: "Tap. Talk. Treat. The Future of Dentistry Is Here.",
      image: Assets.pngs.landing2.keyName,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: animationDuration,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  children: children,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: paddingXL),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(children.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(
                        horizontal: paddingSmall,
                      ),
                      height: 3.h,
                      width: _currentPage == index ? 28.h : 16.h,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white.withAlpha(.4.alpha),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    );
                  }),
                ),
              ),
              Container(
                height: 170.h,
                width: ScreenUtil().screenWidth,
                padding: EdgeInsets.symmetric(horizontal: paddingXL),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 57.h,
                    width: 57.h,
                    child: IconButton.filled(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.white),
                      ),
                      onPressed: () {
                        if (_currentPage == children.length - 1) {
                          navigate(context, PhoneVerification.path);
                        } else {
                          _goToNextPage();
                        }
                      },
                      icon: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
