import 'package:flutter/material.dart';

import '../exporter.dart';

class CommonBottomSheet extends StatelessWidget {
  const CommonBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.popButton,
  });

  final Widget child;

  final String? title;

  final Widget? popButton;

  @override
  Widget build(BuildContext context) {
    double bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(paddingXL),
            child: child,
          ),
          Positioned(
              top: paddingXL,
              right: paddingXL,
              left: paddingXL,
              child: Row(
                children: [
                  Expanded(
                      child: Text(
                    title ?? "",
                  )),
                  popButton ??
                      InkWell(
                        borderRadius: BorderRadius.circular(paddingXL),
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(paddingSmall),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                      ),
                ],
              ))
        ],
      ),
    );
  }
}
