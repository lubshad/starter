import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/utils.dart';

ThemeData get themeData => ThemeData(
    fontFamily: "Roboto",
    useMaterial3: true,
    platform: TargetPlatform.iOS,
    colorScheme: const ColorScheme.light(primary: Colors.black));

extension BuildContextExtension on BuildContext {
  TextStyle get headlineLarge => textTheme.headlineLarge!;
  TextStyle get headlineMedium => textTheme.headlineMedium!;

  TextStyle get headlineSmall => textTheme.headlineSmall!;

  TextStyle get titleLarge => textTheme.titleLarge!;

  TextStyle get titleMedium => textTheme.titleMedium!;

  TextStyle get bodyLarge => textTheme.bodyLarge!;

  TextStyle get labelLarge => textTheme.labelLarge!;

  TextStyle get bodySmall => textTheme.bodySmall!;
}

ButtonStyle get shrinkedButton => TextButton.styleFrom(
    minimumSize: const Size(0, 0),
    padding: EdgeInsets.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap);

setSystemOverlay() {
  if (kIsWeb) return;
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));
}

RoundedRectangleBorder bottomSheetShape() {
  return const RoundedRectangleBorder();
}
