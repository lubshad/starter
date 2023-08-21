import 'package:flutter/material.dart';
import 'package:starter/main.dart';

void showErrorMessage(String message) {
  ScaffoldMessenger.of(navigatorKey.currentState!.context)
      .showSnackBar(SnackBar(content: Text(message)));
}
