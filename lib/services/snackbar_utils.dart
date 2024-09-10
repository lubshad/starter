import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';

import '../exporter.dart';
import '../main.dart';
import '../widgets/default_loading_widget.dart';

void showErrorMessage(message) {
  HapticFeedback.heavyImpact();
  Fluttertoast.showToast(
    backgroundColor: Colors.red,
    msg: message.toString(),
    toastLength: Toast.LENGTH_LONG,
  );
}

String messageFromResponse(Response response) {
  return response.data["message"] ?? "";
}

void showSuccessMessage(message) {
  Fluttertoast.showToast(
    backgroundColor: Colors.green,
    msg: message.toString(),
    toastLength: Toast.LENGTH_LONG,
  );
}

showLoading() {
  showDialog(
      barrierDismissible: false,
      context: navigatorKey.currentContext!,
      builder: (context) => const LoadingWidget());
}

stopLoading() {
  Navigator.pop(navigatorKey.currentContext!, true);
}

void showErrorDialog(String? errorMessage) {
  HapticFeedback.heavyImpact();
  showDialog(
      context: navigatorKey.currentState!.context,
      builder: (context) => Dialog(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                  padding: const EdgeInsets.all(paddingLarge),
                  child: Lottie.asset(Assets.lotties.invalid)),
              Text(
                errorMessage ?? "Somethig went wrong",
                textAlign: TextAlign.center,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Ooops!"),
                    ),
                  ),
                ],
              ),
            ],
          )));
}
