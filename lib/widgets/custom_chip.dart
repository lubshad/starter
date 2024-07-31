// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../exporter.dart';

class CustomChip extends StatelessWidget {
  const CustomChip({
    super.key,
    this.onRemove,
    required this.text,
    this.color = primaryColor,
  });

  final String text;
  final Color color;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: padding,
        vertical: paddingSmall,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(paddingXL),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
          ),
          gapSmall,
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(paddingLarge),
                onTap: onRemove,
                child: Padding(
                  padding: const EdgeInsets.all(
                    paddingTiny * 1.5,
                  ),
                  child: Icon(
                    Icons.clear,
                    color: color,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
