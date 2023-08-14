import 'package:flutter/material.dart';

final scaffoldMessengetKey =
    GlobalKey<ScaffoldMessengerState>(debugLabel: "scaffoldMessnger");
void showErrorMessage(String message) {
  ScaffoldMessenger.of(scaffoldMessengetKey.currentState!.context)
      .showSnackBar(SnackBar(content: Text(message)));
}
