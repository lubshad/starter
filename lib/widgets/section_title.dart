import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../exporter.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.showAction = true,
    this.pding,
    this.onTap,
  });
  final String title;
  final bool showAction;
  final EdgeInsets? pding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: pding ?? EdgeInsets.only(bottom: padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: context.kanit50018.copyWith(color: Color(0xff3C3F4E)),
            ),
          ),
          Visibility(
            visible: showAction,
            child: TextButton(
              onPressed: onTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "See all".tr,
                    style: context.kanit40018.copyWith(
                      color: Color(0xff666666),
                    ),
                  ),
                  gap,
                  SvgPicture.asset(Assets.svgs.arrowRightCircle),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
