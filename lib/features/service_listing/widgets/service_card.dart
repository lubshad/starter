import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../../exporter.dart';
import '../../../widgets/user_avatar.dart';

class ServiceCard extends StatelessWidget {
  final String text;
  final String image;
  final Function()? onTap;
  final bool grid;
  const ServiceCard({
    super.key,
    required this.text,
    required this.image,
    this.onTap,
    this.grid = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.h,
      margin: EdgeInsets.symmetric(horizontal: paddingTiny),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Builder(
              builder: (context) {
                final child = Padding(
                  padding: EdgeInsets.symmetric(horizontal: paddingSmall),
                  child: SizedBox(
                    height: 68.h,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: ShapeDecoration(
                          color: Color(0xFFFAFFFE),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1.19,
                              color: Color(0xFFEBEBEB),
                            ),
                            borderRadius: BorderRadius.circular(48.72),
                          ),
                        ),
                        child: UserAvatar(imageUrl: image),
                      ),
                    ),
                  ),
                );

                return child;
              },
            ),
            gapSmall,
            AutoSizeText(
              breakLines(text),
              // text,
              textAlign: TextAlign.center,
              // maxLines: 2,
              maxLines: findMaxLines(text),
              minFontSize: 1,
              style: context.kanit40011.copyWith(
                color: Color(0xff242222),
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String breakLines(String text) {
  if (Get.locale?.languageCode == "ar") return text;
  final split = text.split(" ");
  if (split.length > 2) {
    return "${split.sublist(0, 2).join("\n")} ${split.sublist(2).join(" ")}";
  }
  return split.join(" ");
}

int findMaxLines(String text) {
  final split = text.split(" ");
  return split.length >= 2 ? 2 : 1;
}
