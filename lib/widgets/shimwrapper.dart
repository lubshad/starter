import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../exporter.dart';

class Shimwrapper extends StatelessWidget {
  const Shimwrapper({
    super.key,
    required this.child,
    this.color,
  });

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(paddingLarge),
          color: Colors.grey.withOpacity(.1)),
      child: Opacity(
        opacity: 0,
        child: child,
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .shimmer(duration: const Duration(seconds: 1), color: color);
  }
}
