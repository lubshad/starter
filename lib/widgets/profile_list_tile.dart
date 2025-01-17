import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';

import '../exporter.dart';

class ProfileListTile extends StatefulWidget {
  const ProfileListTile({
    super.key,
    required this.title,
    this.leading,
    this.onTap,
    this.child,
    this.contentPadding,
    this.trailing,
    this.expandable = false,
    this.selected = false,
  });

  final String title;
  final Widget? leading;
  final VoidCallback? onTap;
  final Widget? child;
  final EdgeInsets? contentPadding;
  final Widget? trailing;
  final bool expandable;
  final bool selected;

  @override
  State<ProfileListTile> createState() => _ProfileListTileState();
}

class _ProfileListTileState extends State<ProfileListTile>
    with SingleTickerProviderStateMixin {
  @override
  initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Animate.defaultDuration,
    );
  }

  late AnimationController animationController;

  bool get expanded => animationController.isCompleted;

  tougleExpansion() {
    if (expanded) {
      animationController.reverse();
    } else {
      animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.selected
          ? Colors.white.withValues(alpha: .2)
          : Colors.transparent,
      child: InkWell(
        onTap: widget.expandable
            ? tougleExpansion
            : () {
                Scaffold.of(context).closeDrawer();
                widget.onTap!();
              },
        child: Padding(
          padding: widget.contentPadding ??
              const EdgeInsets.symmetric(
                  horizontal: padding * 3, vertical: paddingSmall * 3),
          child: Column(
            children: [
              Row(
                children: [
                  if (widget.leading != null)
                    Padding(
                        padding: const EdgeInsets.only(right: padding),
                        child: widget.leading),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: context.labelLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                      animation: animationController,
                      child: widget.trailing ??
                          SvgPicture.asset(Assets.svgs.arrowRight),
                      builder: (context, child) {
                        return Transform.rotate(
                            angle: animationController
                                .drive(
                                    Tween<double>(begin: 0, end: pi / 2).chain(
                                  CurveTween(
                                    curve: Curves.fastOutSlowIn,
                                  ),
                                ))
                                .value,
                            child: child!);
                      }),
                ],
              ),
              AnimatedBuilder(
                  animation: animationController,
                  builder: (context, child) {
                    return ClipRRect(
                      child: Align(
                          heightFactor: CurvedAnimation(
                                  parent: animationController,
                                  curve: Curves.fastOutSlowIn)
                              .value,
                          child: widget.child ?? const SizedBox()),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
