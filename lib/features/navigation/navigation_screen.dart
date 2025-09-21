import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../exporter.dart';
import '../../main.dart';
import '../../mixins/force_update.dart';
import '../../widgets/common_sheet.dart';
import '../../widgets/loading_button.dart';
import 'models/screens.dart';

class NavigationController extends ValueNotifier<Screens> {
  NavigationController(super._value);
}

final navigationController = NavigationController(Screens.home);

class NavigationScreen extends StatefulWidget {
  static const String path = "/navigation";

  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen>
    with ForceUpdateMixin, WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    checkVersion();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.resumed:
        checkVersion();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.paused:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: navigationController,
      builder: (context, child) {
        return PopScope(
          onPopInvokedWithResult: onPopInvoked,
          canPop: false,
          child: Scaffold(
            drawerEnableOpenDragGesture: false,
            // drawer: const ProfileDrawer(),
            body: IndexedStack(
              index: navigationController.value.index,
              children: Screens.values.map((e) => e.body).toList(),
            ),
            bottomNavigationBar: Builder(
              builder: (context) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    BottomNavigationBar(
                      onTap: (value) {
                        if (navigationController.value.index == value) {
                          Screens.values[value].popAll();
                        }
                        navigationController.value = Screens.values[value];
                      },
                      currentIndex: navigationController.value.index,
                      items: Screens.values
                          .map(
                            (screen) => BottomNavigationBarItem(
                              backgroundColor: Colors.white,
                              activeIcon: screen.activeIcon,
                              label: screen.label,
                              icon: screen.bottomIcon,
                            ),
                          )
                          .toList(),
                    ),
                    Positioned(
                      top: -30.h,
                      left: 0,
                      right: 0,
                      child: Row(
                        children: Screens.values
                            .map(
                              (e) => Expanded(
                                child: Visibility(
                                  visible: navigationController.value == e,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      height: 60.h,
                                      width: 60.h,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Color(0xffF5F5F5),
                                          width: 8.h,
                                        ),
                                      ),
                                      child: e.activeIcon,
                                    ).animate().fade().slideY(begin: .5),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void onPopInvoked(bool didPop, dynamic result) async {
    if (Navigator.canPop(navigationController.value.context)) {
      Navigator.maybePop(navigationController.value.context);
    } else {
      final result = await showModalBottomSheet(
        context: navigatorKey.currentContext!,
        builder: (context) => CommonBottomSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              gapXL,
              const Text("You are about to exit from the app"),
              gapXL,
              LoadingButton(
                buttonLoading: false,
                text: "Exit",
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ),
      );
      if (result == null) return;
      SystemNavigator.pop(animated: true);
    }
  }
}
