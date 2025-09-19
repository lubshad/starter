import 'package:flutter/material.dart';

import '../../core/app_route.dart';
import '../../core/repository.dart';
import '../../exporter.dart';
import '../../mixins/user_image_mixin.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/user_avatar.dart';
import '../update_profile/update_profile_screen.dart';
import 'common_controller.dart';

class ProfileScreen extends StatefulWidget {
  static const String path = "/profile-screen";

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with UserImageMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          profileTopSection(context),
          Expanded(
            child: DefaultTabController(
              length: 5,
              child: TabBarTheme(
                data: smallTabbarTheme,
                child: Column(
                  children: [
                    TabBar(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      isScrollable: true,
                      tabs: [
                        Tab(text: "About Me"),
                        Tab(text: "Services"),
                        Tab(text: "Gallery"),
                        Tab(text: "Offers"),
                        Tab(text: "Reviews"),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          Placeholder(),
                          Placeholder(),
                          Placeholder(),
                          Placeholder(),
                          Placeholder(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget profileTopSection(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 430 / 271,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff012036),
                      Color(0xff001734),
                      Color(0xff0A353F),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              height: 70.h,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(paddingXL),
                  ),
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              height: 140.h,
              bottom: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 140.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.all(paddingSmall),
                  child: Stack(
                    children: [
                      UserAvatar(size: 135.h, imageUrl: randomProfileImage),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton.filled(
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              Colors.black.withAlpha(.5.alpha),
                            ),
                          ),
                          onPressed: () => showImagePicker(
                            image: "profile",
                            onChanged: () {
                              DataRepository.i.updateProfileDetails(
                                CommonController.i.profileDetails!,
                              );
                            },
                          ),
                          icon: Icon(Icons.camera_alt, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              // child: AppBar(),
              child: CustomAppBar(
                title: "Profile",
                borderColor: Colors.transparent,
                textStyle: context.kanit50023.copyWith(color: Colors.white),
                actions: SizedBox(
                  width: 104.h,
                  child: LoadingButton(
                    textColor: Colors.white,
                    buttonType: ButtonType.outlined,
                    aspectRatio: 104 / 31,
                    buttonLoading: false,
                    text: "Edit Profile",
                    onPressed: () =>
                        navigate(context, UpdateProfileScreen.path),
                  ),
                ),
              ),
            ),
          ],
        ),
        gap,
        Text(
          CommonController.i.profileDetails?.name ?? "",
          style: context.bodySmall.copyWith(color: Color(0xff3C3F4E)),
        ),
        Text(
          CommonController.i.profileDetails?.email ?? "",
          style: context.bodySmall.copyWith(color: Color(0xff666666)),
        ),
        gapLarge,
        Divider(thickness: 5.h, height: 0, color: Color(0xffF5F5F5)),
      ],
    );
  }
}
