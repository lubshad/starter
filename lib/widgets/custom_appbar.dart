import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../exporter.dart';
import '../features/navigation/models/screens.dart';
import '../features/navigation/navigation_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.onPop,
    this.textStyle,
    this.borderColor,
    this.actions,
    this.showBorder = true,
    this.subtitle,
  });

  final String title;
  final VoidCallback? onPop;
  final TextStyle? textStyle;
  final Color? borderColor;
  final Widget? actions;
  final bool showBorder;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    setSystemOverlay();
    return Container(
      padding: EdgeInsets.only(
        top: paddingXXL,
        left: middlePadding,
        right: middlePadding,
        bottom: paddingLarge,
      ),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(
                bottom: BorderSide(color: borderColor ?? Color(0XffEBEBEB)),
              )
            : null,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed:
                onPop ??
                () {
                  if (Navigator.canPop(context)) {
                    Navigator.maybePop(context);
                  } else {
                    navigationController.value = Screens.home;
                  }
                },
            icon: Icon(Icons.arrow_back),

            style: IconButton.styleFrom(
              backgroundColor: Color(0XffF5F5F5),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          gapLarge,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AutoSizeText(
                        title,
                        style:
                            textStyle ??
                            context.kanit50023.copyWith(
                              color: Color(0xff1C1F1D),
                            ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: context.kanit30014.copyWith(
                      color: Color(0xff666666),
                    ),
                    maxLines: 1,
                  ),
              ],
            ),
          ),
          gap,
          actions ?? SizedBox(),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size(ScreenUtil().screenWidth, kToolbarHeight * 2);
}
