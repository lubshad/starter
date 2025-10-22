import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../gen/assets.gen.dart';

class CurrencyAmountWidget extends StatelessWidget {
  final double amount;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  final MainAxisAlignment? alignment;
  final CrossAxisAlignment? crossAlignment;

  const CurrencyAmountWidget({
    super.key,
    required this.amount,
    this.fontSize,
    this.color,
    this.fontWeight,
    this.alignment,
    this.crossAlignment,
  });

  @override
  Widget build(BuildContext context) {
    final defaultColor = color ?? Colors.black;
    final defaultFontSize = fontSize ?? 16.0;
    final defaultFontWeight = fontWeight ?? FontWeight.normal;

    return Row(
      mainAxisAlignment: alignment ?? MainAxisAlignment.start,
      crossAxisAlignment: crossAlignment ?? CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Saudi Riyal Icon
        ColorFiltered(
          colorFilter: ColorFilter.mode(defaultColor, BlendMode.srcIn),
          child: Assets.pngs.saudiRiyal.image(
            width: defaultFontSize * 0.8,
            height: defaultFontSize * 0.8,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(width: 4.w),
        // Formatted Amount
        Text(
          _formatAmount(amount),
          style: TextStyle(
            fontSize: defaultFontSize,
            color: defaultColor,
            fontWeight: defaultFontWeight,
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    // Format to 2 decimal places and add thousand separators
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]},',
        );
  }
}
