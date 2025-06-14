import 'package:flutter/material.dart';

import '../constants.dart';

class BottomButtonPadding extends StatelessWidget {
  const BottomButtonPadding({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    var insetsPadding = MediaQuery.of(context).viewInsets.bottom;
    insetsPadding += paddingLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: paddingLarge,
        vertical: paddingLarge,
      ).copyWith(
        bottom: insetsPadding,
      ),
      child: child,
    );
  }
}
