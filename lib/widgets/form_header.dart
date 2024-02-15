import 'package:flutter/material.dart';
import '../exporter.dart';

class FormHeader extends StatelessWidget {
  const FormHeader({
    super.key,
    required this.child,
    required this.label,
    this.requred = true,
  });
  final Widget child;
  final String label;
  final bool requred;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(
              left: padding,
              bottom: paddingSmall,
            ),
            child: Text(
              label,
              style: context.bodyLarge,
            )),
        child,
      ],
    );
  }
}
