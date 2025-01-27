import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/app_config.dart';
import '../../core/repository.dart';
import '../../exporter.dart';
import '../../main.dart';
import '../../services/shared_preferences_services.dart';
import '../../widgets/common_sheet.dart';
import '../../widgets/loading_button.dart';
import '../authentication/phone_auth/phone_auth_screen.dart';
import '../navigation/models/screens.dart';
import '../navigation/navigation_screen.dart';
import '../web_view/web_view_screen.dart';
import 'common_controller.dart';
import 'profile_details_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<ProfileDetailsModel>? future;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    future = DataRepository.i.fetchProfileDetails();
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {});
  }

  PackageInfo? packageInfo;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Center(
          child: Padding(
        padding: const EdgeInsets.all(paddingLarge),
        child: Column(
          children: [
            const Spacer(),
            LoadingButton(
                buttonLoading: false,
                text: "LOGOUT",
                onPressed: () => signOut()),
            if (packageInfo != null)
              Padding(
                  padding: const EdgeInsets.only(bottom: paddingXL),
                  child: Text("Version : ${packageInfo!.version}"))
          ],
        ),
      )),
    );
  }
}

void showRefundPolicy() {
  Navigator.pushNamed(
      navigatorKey.currentContext!,
      Uri(path: WebViewScreen.path, queryParameters: {
        "title": "Refund Policy",
        "url": appConfig.baseUrl
      }).toString());
}

void showTermsAndConditions() {
  Navigator.pushNamed(
      navigatorKey.currentContext!,
      Uri(path: WebViewScreen.path, queryParameters: {
        "title": "Terms & Conditions",
        "url": appConfig.baseUrl
      }).toString());
}

void showPrivacyPolicy() {
  Navigator.pushNamed(
      navigatorKey.currentContext!,
      Uri(path: WebViewScreen.path, queryParameters: {
        "title": "Privacy Policy",
        "url": appConfig.baseUrl
      }).toString());
}

logout() async {
  final result = await showModalBottomSheet(
    context: navigatorKey.currentContext!,
    builder: (context) => CommonBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          gapXXL,
          Text("You are about to logout from the app"),
          gapLarge,
          LoadingButton(
            buttonLoading: false,
            text: "Logout",
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    ),
  );
  if (result == null) return;
  signOut();
}

void signOut() {
  SharedPreferencesService.i.clear();
  CommonController.i.clear();
  navigationController.value = Screens.home;

  FirebaseAuth.instance.signOut();
  Navigator.pushNamedAndRemoveUntil(
      navigatorKey.currentContext!, PhoneVerification.path, (route) => false);
}
