
import 'package:gap/gap.dart';

delayed({Duration duration = const Duration(seconds: 2)}) async {
  return await Future.delayed(duration);
}

const double padding = 8;
const double paddingLarge = 16;
const double paddingXL = 32;
const double paddingXXL = 64;
const double paddingSmall =  4;
const double paddingTiny =  2;

const gap = Gap(padding);
const gapLarge = Gap(paddingLarge);
const gapXL = Gap(paddingXL);
const gapXXL = Gap(paddingXXL);
const gapSmall = Gap(paddingSmall);
const gapTiny = Gap(paddingTiny);

const Duration animationDuration = Duration(milliseconds: 300);
const Duration animationDurationLarge = Duration(seconds: 1);
