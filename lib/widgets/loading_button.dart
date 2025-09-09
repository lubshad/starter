import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../exporter.dart';

enum ButtonType {
  outlined,
  filled;

  BoxBorder? get border {
    switch (this) {
      case ButtonType.outlined:
        return Border.all(
          color: const Color(0xffC9C9C9),
          width: 1,
        );
      case ButtonType.filled:
        return null;
    }
  }

  LinearGradient get gradient {
    switch (this) {
      case ButtonType.outlined:
        return buttonGradient;
      case ButtonType.filled:
        return buttonGradient;
    }
  }

  Color? get color {
    switch (this) {
      case ButtonType.outlined:
        return Colors.transparent;
      case ButtonType.filled:
        return null;
    }
  }

  Color? get textColor {
    switch (this) {
      case ButtonType.outlined:
        return const Color(0xff000000);
      case ButtonType.filled:
        return Colors.white;
    }
  }
}

class LoadingButton extends StatelessWidget {
  const LoadingButton({
    this.aspectRatio = 317 / 47,
    this.icon,
    super.key,
    required this.buttonLoading,
    required this.text,
    required this.onPressed,
    this.enabled = true,
    this.expanded = true,
    this.textColor = Colors.white,
    this.backgroundColor,
    this.buttonType = ButtonType.filled,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
  });

  final bool buttonLoading;
  final Color textColor;
  final String text;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry padding;
  final bool enabled;
  final Color? backgroundColor;
  final bool expanded;
  final Widget? icon;
  final ButtonType buttonType;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(
      paddingXL,
    );
    Widget button = AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          border: buttonType.border,
          gradient: buttonType.gradient,
          borderRadius: borderRadius,
          color: buttonType.color,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: buttonLoading
                ? null
                : () {
                    FocusScope.of(context).unfocus();
                    HapticFeedback.lightImpact();
                    onPressed();
                  },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.center,
              child: Builder(builder: (context) {
                if (buttonLoading) return const CircularProgressIndicator();
                final textWidget = Text(
                  text,
                  style: context.labelLarge.copyWith(
                    fontSize: 15.r,
                    color: buttonType.textColor,
                  ),
                );
                if (icon != null) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [icon!, gap, textWidget],
                  );
                }
                return textWidget;
              }),
            ),
          ),
        ),
      ),
    );
    if (expanded) {
      return Row(
        children: [Expanded(child: button)],
      );
    } else {
      return button;
    }
  }
}
