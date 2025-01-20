// ignore_for_file: deprecated_member_use

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
    this.textColor = const Color(0xff535763),
    this.selectionColor =
        const LinearGradient(colors: [Colors.blue, Colors.blue]),
    this.borderRadius = padding,
    this.margin,
    this.isExpaned = false,
  });

  final String title;
  final Widget? leading;
  final VoidCallback? onTap;
  final Widget? child;
  final EdgeInsets? contentPadding;
  final Widget? trailing;
  final bool expandable;
  final bool selected;
  final Color textColor;
  final Gradient selectionColor;
  final double borderRadius;
  final EdgeInsets? margin;
  final bool isExpaned;

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
    if (widget.isExpaned) {
      tougleExpansion();
    }
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
    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        gradient: widget.selected ? widget.selectionColor : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        onTap: widget.expandable
            ? tougleExpansion
            : () {
                if (widget.onTap == null) return;
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
                        color: widget.textColor,
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                      animation: animationController,
                      child: widget.trailing ??
                          SvgPicture.asset(
                            Assets.svgs.arrowRight,
                            color: widget.textColor,
                          ),
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
