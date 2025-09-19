import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../exporter.dart';

TextStyle baseStyle = const TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: Colors.black,
);

final hintStyle = baseStyle.copyWith(
  fontWeight: FontWeight.w400,
  fontSize: 13.5,
  color: const Color(0xff868686),
);

TabBarThemeData get smallTabbarTheme => TabBarThemeData(
  tabAlignment: TabAlignment.start,
  dividerColor: Color(0xffEBEBEB),
  labelColor: Color(0xff1A2338),
  unselectedLabelColor: Color(0xff989898),
);

ThemeData get themeData => ThemeData(
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: primaryColor,
    unselectedItemColor: const Color(0xff8E8E8E),
    showUnselectedLabels: true,
    selectedLabelStyle: baseStyle.copyWith(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
    ),
    unselectedLabelStyle: baseStyle.copyWith(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
    ),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(paddingXL)),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(200, 54),
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(padding),
      ),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(border: InputBorder.none),
  fontFamily: "Roboto",
  useMaterial3: true,
  platform: TargetPlatform.iOS,
  colorScheme: const ColorScheme.light(primary: Colors.black),
);

extension BuildContextExtension on BuildContext {
  TextStyle get headlineLarge => textTheme.headlineLarge!;
  TextStyle get headlineMedium => textTheme.headlineMedium!;

  TextStyle get headlineSmall => textTheme.headlineSmall!;

  TextStyle get titleLarge => textTheme.titleLarge!;

  TextStyle get titleMedium => textTheme.titleMedium!;

  TextStyle get bodyLarge => textTheme.bodyLarge!;

  TextStyle get labelLarge => textTheme.labelLarge!;

  TextStyle get bodySmall => textTheme.bodySmall!;

  TextStyle get montserrat50016 =>
      baseStyle.copyWith(fontSize: 16.sp, fontWeight: FontWeight.w500);
  TextStyle get montserrat50017 =>
      baseStyle.copyWith(fontSize: 17.sp, fontWeight: FontWeight.w500);

  TextStyle get montserrat40013 => baseStyle.copyWith(
    fontSize: 13.sp,
    fontWeight: FontWeight.w400,
    color: Color(0xff9A9BB1),
  );
  TextStyle get montserrat50014 => baseStyle.copyWith(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
  TextStyle get montserrat60016 =>
      baseStyle.copyWith(fontSize: 16.sp, fontWeight: FontWeight.w600);
  TextStyle get montserrat40014 =>
      baseStyle.copyWith(fontSize: 14.sp, fontWeight: FontWeight.w400);
  // montserrat60015 
  TextStyle get montserrat60015 =>
      baseStyle.copyWith(fontSize: 15.sp, fontWeight: FontWeight.w600);
  // montserrat50013
  TextStyle get montserrat50013 => baseStyle.copyWith(fontSize: 13.sp, fontWeight: FontWeight.w500);
  //montserrat40012
  TextStyle get montserrat40012 => baseStyle.copyWith(fontSize: 12.sp, fontWeight: FontWeight.w400);
  //montserrat60013
  TextStyle get montserrat60013 => baseStyle.copyWith(fontSize: 13.sp, fontWeight: FontWeight.w600);
  //montserrat30013
  TextStyle get montserrat30013 => baseStyle.copyWith(fontSize: 13.sp, fontWeight: FontWeight.w300);
  //montserrat70017
  TextStyle get montserrat70017 => baseStyle.copyWith(fontSize: 17.sp, fontWeight: FontWeight.w700);

  TextStyle get kanit50023 => baseStyle.copyWith(fontSize: 23.sp, fontWeight: FontWeight.w500);
}

ButtonStyle get shrinkedButton => TextButton.styleFrom(
  minimumSize: const Size(0, 0),
  padding: EdgeInsets.zero,
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
);

void setSystemOverlay() {
  if (kIsWeb) return;
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
}

RoundedRectangleBorder bottomSheetShape() {
  return const RoundedRectangleBorder();
}
