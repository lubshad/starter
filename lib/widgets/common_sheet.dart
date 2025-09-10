import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
// import 'package:printer_utils/models/printer_model.dart';

import '../exporter.dart';
import 'loading_button.dart';

class CommonBottomSheet extends StatelessWidget {
  const CommonBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.popButton,
    this.maxWidth,
    this.headerWidget,
  });

  final Widget child;

  final String? title;

  final Widget? popButton;
  final double? maxWidth;
  final Widget? headerWidget;

  @override
  Widget build(BuildContext context) {
    double bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return Material(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(paddingXL),
        bottom: ScreenUtil().deviceType(context) == DeviceType.mobile
            ? Radius.zero
            : Radius.circular(paddingXL),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? (context.width < 600 ? double.infinity : 400),
        ),
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                headerWidget ??
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: paddingSmall,
                          horizontal: paddingXXL,
                        ),
                        child: AutoSizeText(
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          (title ?? ""),
                          style: context.labelLarge.copyWith(
                            fontSize:
                                ScreenUtil().deviceType(context) ==
                                    DeviceType.mobile
                                ? 20.sp
                                : 40.sp,
                          ),
                        ),
                      ),
                    ),

                Positioned(
                  left: 0,
                  right: paddingLarge,
                  top: 10,
                  bottom: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Spacer(),
                      popButton ??
                          InkWell(
                            borderRadius: BorderRadius.circular(paddingXL),
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              // padding: const EdgeInsets.all(paddingSmall),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF7CAC),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(padding: const EdgeInsets.all(paddingXL), child: child),
          ],
        ),
      ),
    );
  }
}

class ConfirmationSheet extends StatelessWidget {
  const ConfirmationSheet({
    super.key,
    required this.buttonText,
    required this.text,
  });

  final String text;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return CommonBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text),
          gapLarge,
          LoadingButton(
            buttonLoading: false,
            text: buttonText,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }
}

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
