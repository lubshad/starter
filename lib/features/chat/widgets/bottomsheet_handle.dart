import 'package:flutter/material.dart';
import 'package:starter/exporter.dart';

class BottomSheetHandle extends StatelessWidget {
  const BottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: paddingLarge),
      child: Container(
        width: 40.w,
        height: 4.w,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(2.h),
        ),
      ),
    );
  }
}
