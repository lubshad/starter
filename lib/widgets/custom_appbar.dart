// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../exporter.dart';
import '../features/navigation/models/screens.dart';
import '../features/navigation/navigation_screen.dart';

IconButtonCustom backButtonWithSafety(
  BuildContext context, {
  VoidCallback? onTap,
}) {
  return IconButtonCustom(
    onTap:
        onTap ??
        () {
          FocusScope.of(context).unfocus();
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            navigationController.value = Screens.home;
          }
        },
  );
}

// ignore: must_be_immutable
class IconButtonCustom extends StatelessWidget {
  IconButtonCustom({
    super.key,
    required this.onTap,
    this.color = const Color(0xffEDF2FF),
    this.child,
  });

  final VoidCallback onTap;
  final Color color;
  Widget? child;

  @override
  Widget build(BuildContext context) {
    child ??= Transform.rotate(
      angle: pi,
      child: SvgPicture.asset(
        Assets.svgs.arrowRight,
        color: Colors.black,
        width: 13,
        height: 13,
      ),
    );
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: InkWell(
          customBorder: CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(kToolbarHeight / 4),
            child: child,
          ),
        ),
      ),
    );
  }
}

Widget titleWithEventName({
  required String title,
  Widget? subWidget,
  required BuildContext context,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        title,
        style: context.montserrat30013.copyWith(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      gapTiny,
      subWidget ?? SizedBox.shrink(),
    ],
  );
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.leading,
    this.subWidget,
    this.appbarContext,
    this.bottom,
    this.backgroundColor,
    this.isCenterTitle = true,
  });
  final String title;
  final List<Widget> actions;
  final Widget? leading;
  final bool isCenterTitle;
  final Widget? subWidget;
  final PreferredSizeWidget? bottom;
  final BuildContext? appbarContext;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      centerTitle: isCenterTitle,
      surfaceTintColor: Colors.transparent,
      actions: actions.isEmpty
          ? [
              IconButton(
                onPressed: () {
                  Scaffold.of(appbarContext ?? context).openDrawer();
                },
                icon: Icon(Icons.menu),
              ),
              gap,
            ]
          : actions,
      leading: leading ?? backButtonWithSafety(context),
      leadingWidth: leadingWidth,
      title: subWidget != null
          ? titleWithEventName(
              title: title,
              subWidget: subWidget,
              context: context,
            )
          : Text(
              title,
              style: context.montserrat70017.copyWith(color: Color(0xff3C3F4E)),
            ),
      bottom: bottom,
    );
  }

  // @override
  // Size get preferredSize => AppBar().preferredSize;

  @override
  Size get preferredSize {
    return Size.fromHeight(
      kToolbarHeight + (bottom?.preferredSize.height ?? 0),
    );
  }
}
