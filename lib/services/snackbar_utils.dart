import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:toastification/toastification.dart';

import '../exporter.dart';
import '../main.dart';
import '../widgets/default_loading_widget.dart';
import '../widgets/loading_button.dart';

void showErrorMessage(dynamic message, {Widget? icon}) {
  HapticFeedback.heavyImpact();
  toastification.dismissAll();
  toastification.show(
    title: Text(message.toString()),
    type: ToastificationType.error,
    style: ToastificationStyle.minimal,
    alignment: Alignment.bottomCenter,
    autoCloseDuration: const Duration(seconds: 3),
    icon: icon,
  );
}

void showSuccessMessage(dynamic message, {Widget? icon}) {
  toastification.dismissAll();
  toastification.show(
    title: Text(message),
    type: ToastificationType.success,
    style: ToastificationStyle.minimal,
    alignment: Alignment.bottomCenter,
    autoCloseDuration: const Duration(seconds: 3),
    icon: icon,
  );
}

void showLoading() {
  showDialog(
      barrierDismissible: false,
      context: navigatorKey.currentContext!,
      builder: (context) => const LoadingWidget());
}

void stopLoading() {
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


void showAlertDialogCustom(String message) {
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