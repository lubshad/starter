import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';

import '../../../../constants.dart';

class LandingScreenItem extends StatelessWidget {
  const LandingScreenItem(
      {super.key, this.image, this.title, this.description});
  final String? image;
  final String? title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset(image.toString()),
        gapLarge,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: paddingXL),
          child: Column(
            children: [
              Text(
                title.toString(),
                textAlign: TextAlign.center,
              ),
              gap,
              Text(
                description.toString(),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ],
    );
  }
}
