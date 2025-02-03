import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';

import '../exporter.dart';
import '../main.dart';
import '../widgets/default_loading_widget.dart';
import '../widgets/loading_button.dart';

Future<bool> checkConnectivity() async {
  final positiveResult = [
    ConnectivityResult.mobile,
    ConnectivityResult.wifi,
  ];
  final result = await Connectivity().checkConnectivity();
  if (!result.any(
    (element) => positiveResult.contains(element),
  )) {
    return false;
  }
  return true;
}

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


showAlertDialogCustom(String message) {
  HapticFeedback.heavyImpact();
  showDialog(
    context: navigatorKey.currentContext!,
    builder: (context) {
      return CustomAlertDialog(text: message);
    },
  );
}

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsPadding: EdgeInsets.symmetric(
        horizontal: paddingXXL,
        vertical: paddingXL,
      ),
      actions: [
        LoadingButton(
          aspectRatio: 369 / 100,
          buttonLoading: false,
          text: "OK",
          onPressed: () => Navigator.pop(context, true),
        )
      ],
      contentPadding: EdgeInsets.only(top: paddingXL * 1.5),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: context.labelLarge.copyWith(
              color: Color(
                0xff3C3F4E,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}