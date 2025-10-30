import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:starter/core/app_route.dart';
import '../../exporter.dart';
import '../../main.dart';
import '../../services/shared_preferences_services.dart';
import '../../widgets/common_sheet.dart';
import '../../widgets/profile_list_tile.dart';
import '../../widgets/user_avatar.dart';
import '../authentication/social_authentication/social_authentication_screen.dart';
import '../navigation/models/screens.dart';
import '../navigation/navigation_screen.dart';
import 'common_controller.dart';
import 'profile_details_model.dart';

Future showConfirmation({
  required String text,
  required String buttonText,
}) async {
  return DeviceType.mobile ==
          ScreenUtil().deviceType(navigatorKey.currentContext!)
      ? await showModalBottomSheet(
          context: navigatorKey.currentContext!,
          builder: (context) =>
              ConfirmationSheet(text: text, buttonText: buttonText),
        )
      : await showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => Center(
            child: ConfirmationSheet(text: text, buttonText: buttonText),
          ),
        );
}

class ProfileDrawer extends StatefulWidget {
  static const String path = "/profile";

  const ProfileDrawer({super.key});

  @override
  State<ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer> {
  Future<ProfileDetailsModel>? future;

  bool isCheckedIn = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    // future = DataRepository.i.fetchProfileDetails();
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {});
  }

  PackageInfo? packageInfo;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: paddingXL),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: paddingXL,
                vertical: paddingXL,
              ).copyWith(bottom: paddingXL),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(paddingTiny),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xffD41D5B), Color(0xffED752E)],
                      ),
                      borderRadius: BorderRadius.circular(paddingXXL),
                    ),
                    child: UserAvatar(
                      borderRadius: paddingXL,
                      size: 51.sp,
                      imageUrl: CommonController.i.profileDetails?.image,
                    ),
                  ),
                  gap,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          CommonController.i.profileDetails?.name ?? "N/A",
                          style: context.labelLarge,
                        ),
                        Text(
                          CommonController.i.profileDetails?.email ?? "N/A",
                          style: context.labelLarge.copyWith(
                            color: Color(0xff999999),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ProfileListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: paddingLarge,
                vertical: paddingLarge,
              ),
              margin: EdgeInsets.symmetric(horizontal: paddingLarge),
              textColor: Colors.white,
              selected: true,
              title: "Home",
              leading: Icon(Icons.dashboard, color: Colors.white),
              selectionColor: LinearGradient(
                colors: [Color(0xffD31B5C), Color(0xffED742F)],
              ),
            ),
            ProfileListTile(
              title: "Log Out",
              leading: Icon(Icons.logout),
              onTap: () async {
                logout();
              },
            ),
            Spacer(),
            if (packageInfo != null)
              Padding(
                padding: const EdgeInsets.only(bottom: paddingXL),
                child: Text(
                  "Version : ${packageInfo!.version}",
                  style: baseStyle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

void showRefundPolicy() {
  // Navigator.pushNamed(
  //     navigatorKey.currentContext!,
  //     Uri(path: WebViewScreen.path, queryParameters: {
  //       "title": "Refund Policy",
  //       "url": appConfig.baseUrl
  //     }).toString());
}

void showTermsAndConditions() {
  // Navigator.pushNamed(
  //     navigatorKey.currentContext!,
  //     Uri(path: WebViewScreen.path, queryParameters: {
  //       "title": "Terms & Conditions",
  //       "url": appConfig.baseUrl
  //     }).toString());
}

void showPrivacyPolicy() {
  // Navigator.pushNamed(
  //     navigatorKey.currentContext!,
  //     Uri(path: WebViewScreen.path, queryParameters: {
  //       "title": "Privacy Policy",
  //       "url": appConfig.baseUrl
  //     }).toString());
}

Future<void> logout() async {
  bool? result = true;
  result = await showConfirmation(
    text:
        "You are about to logout from your account!.Are you sure want to continue?",
    buttonText: "Logout",
  );
  if (result == null) return;
  signOut();
}

void signOut() async {
  navigationController.value = Screens.home;
  await SharedPreferencesService.i.clear();
  CommonController.i.clear();
  await navigate(
    navigatorKey.currentContext!,
    SocialAuthenticationScreen.path,
    replace: true,
  );
}
