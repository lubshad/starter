
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neopop/neopop.dart';

import '../exporter.dart';

class LoadingButton extends StatelessWidget {
  const LoadingButton({
    super.key,
    required this.buttonLoading,
    required this.text,
    required this.onPressed,
    this.enabled = true,
    this.textColor = Colors.white,
    this.backgroundColor = Colors.black,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
  });

  final bool buttonLoading;
  final Color textColor;
  final String text;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry padding;
  final bool enabled;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return NeoPopButton(
      enabled: enabled,
      color: backgroundColor,
      animationDuration: animationDuration,
      depth: 1,
      onTapUp: buttonLoading || !enabled
          ? null
          : () {
              HapticFeedback.lightImpact();
              onPressed();
            },
      onTapDown: () => HapticFeedback.mediumImpact(),
      child: buttonLoading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child:
                  Center(child: FittedBox(child: CircularProgressIndicator())))
          : Padding(
              padding: padding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(text, style: TextStyle(color: textColor)),
                ],
              ),
            ),
    );
  }
}
