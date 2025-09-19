import 'package:flutter/material.dart';

import '../../../../exporter.dart';

class LandingScreenItem extends StatelessWidget {
  const LandingScreenItem({
    super.key,
    this.image,
    this.title,
    this.description,
  });
  final String? image;
  final String? title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: paddingXL,
            vertical: paddingXL,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title.toString(),

                style: context.kanit40036.copyWith(
                  color: Colors.white,
                  height: 41 / 36,
                ),
              ),
              gapLarge,
              Text(
                description.toString(),

                style: context.kanit30016.copyWith(
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          top: 0,
          child: Padding(
            padding: EdgeInsets.only(bottom: 160.h),
            child: Image.asset(image.toString()),
          ),
        ),
      ],
    );
  }
}
