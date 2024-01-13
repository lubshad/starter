import 'package:flutter/material.dart';

delayed({Duration duration = const Duration(seconds: 2)}) async {
  return await Future.delayed(duration);
}

const double padding = 8;
const double paddingSmall = padding / 2;
const double paddingLarge = padding * 2;
const double paddingXL = padding * 4;
const double paddingTiny = paddingSmall / 2;

const gap = SizedBox(height: padding);
const gapXL = SizedBox(height: paddingXL);
const gapLarge = SizedBox(height: paddingLarge);
const gapSmall = SizedBox(height: paddingSmall);
const gapHorizontal = SizedBox(width: padding);
const gapHorizontalLarge = SizedBox(width: paddingLarge);
const gapHorizontalSmall = SizedBox(width: paddingSmall);

const Duration animationDuration = Duration(milliseconds: 300);
const Duration animationDurationLarge = Duration(seconds: 1);
