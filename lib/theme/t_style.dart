import 'package:flutter/material.dart';

class Tstyle {
  static TextStyle get headMedium => const TextStyle(
        fontSize: 28.0,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w800,
        height: 1.08187, // This corresponds to line-height: 108.187%
      );

  static TextStyle get labelLarge => const TextStyle(
        color: Color(0xFF6F7173), // Replace with the desired color value
        fontSize: 14,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w400,
      );

  TextStyle titleMedium = const TextStyle(
    color: Color(0xFFFFFFFF), // Replace with the desired color value
    fontSize: 20.0,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w400,
  );
}
