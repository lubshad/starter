import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../exporter.dart';

enum _SwipeButtonType {
  swipe,
  expand,
}

class SwipeButton extends StatefulWidget {
  final Widget child;
  final Widget? thumb;

  final Color? activeThumbColor;
  final Color? inactiveThumbColor;
  final EdgeInsets thumbPadding;

  final Gradient? activeTrackColor;
  final Gradient? inactiveTrackColor;
  final EdgeInsets trackPadding;

  final BorderRadius? borderRadius;

  final double width;
  final double height;

  final bool enabled;

  final double elevationThumb;
  final double elevationTrack;

  final VoidCallback? onSwipeStart;
  final VoidCallback? onSwipe;
  final VoidCallback? onSwipeEnd;

  final _SwipeButtonType _swipeButtonType;

  final Duration duration;
  final Color? trackElevationColor;
  final Color? thumbElevationColor;

  const SwipeButton({
    super.key,
    this.trackElevationColor,
    this.thumbElevationColor,
    required this.child,
    this.thumb,
    this.activeThumbColor,
    this.inactiveThumbColor,
    this.thumbPadding = EdgeInsets.zero,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.trackPadding = EdgeInsets.zero,
    this.borderRadius,
    this.width = double.infinity,
    this.height = 50,
    this.enabled = true,
    this.elevationThumb = 0,
    this.elevationTrack = 0,
    this.onSwipeStart,
    this.onSwipe,
    this.onSwipeEnd,
    this.duration = const Duration(milliseconds: 250),
  })  : assert(elevationThumb >= 0.0),
        assert(elevationTrack >= 0.0),
        _swipeButtonType = _SwipeButtonType.swipe;

  const SwipeButton.expand({
    this.trackElevationColor,
    this.thumbElevationColor,
    super.key,
    required this.child,
    this.thumb,
    this.activeThumbColor,
    this.inactiveThumbColor,
    this.thumbPadding = EdgeInsets.zero,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.trackPadding = EdgeInsets.zero,
    this.borderRadius,
    this.width = double.infinity,
    this.height = 50,
    this.enabled = true,
    this.elevationThumb = 0,
    this.elevationTrack = 0,
    this.onSwipeStart,
    this.onSwipe,
    this.onSwipeEnd,
    this.duration = const Duration(milliseconds: 250),
  })  : assert(elevationThumb >= 0.0),
        assert(elevationTrack >= 0.0),
        _swipeButtonType = _SwipeButtonType.expand;

  @override
  State<SwipeButton> createState() => _SwipeState();
}

class _SwipeState extends State<SwipeButton> with TickerProviderStateMixin {
  late AnimationController swipeAnimationController;
  late AnimationController expandAnimationController;

  bool swiped = false;

  @override
  void initState() {
    _initAnimationControllers();
    super.initState();
  }

  void _initAnimationControllers() {
    swipeAnimationController = AnimationController(
      vsync: this,
      duration: widget.duration,
      lowerBound: 0,
      upperBound: 1,
      value: 0,
    );
    expandAnimationController = AnimationController(
      vsync: this,
      duration: widget.duration,
      lowerBound: 0,
      upperBound: 1,
      value: 0,
    );
  }

  @override
  void didUpdateWidget(covariant SwipeButton oldWidget) {
    if (oldWidget.duration != widget.duration) {
      _initAnimationControllers();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    swipeAnimationController.dispose();
    expandAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              _buildTrack(context, constraints),
              _buildThumb(context, constraints),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTrack(BuildContext context, BoxConstraints constraints) {
    final ThemeData theme = Theme.of(context);

    final trackColor = widget.enabled
        ? widget.activeTrackColor ??
            LinearGradient(colors: [theme.colorScheme.surface])
        : widget.inactiveTrackColor ??
            LinearGradient(colors: [theme.disabledColor]);

    final borderRadius = widget.borderRadius ?? BorderRadius.circular(150);
    final elevationTrack = widget.enabled ? widget.elevationTrack : 0.0;

    return Padding(
      padding: widget.trackPadding,
      child: Material(
        elevation: elevationTrack,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        shadowColor: widget.trackElevationColor,
        child: Builder(builder: (context) {
          return AnimatedContainer(
            duration: animationDurationLarge,
            curve: Animate.defaultCurve,
            width: constraints.maxWidth,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: trackColor,
              borderRadius: borderRadius,
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: widget.child,
          );
        }),
      ),
    );
  }

  Widget _buildThumb(BuildContext context, BoxConstraints constraints) {
    final ThemeData theme = Theme.of(context);

    final thumbColor = widget.enabled
        ? widget.activeThumbColor ?? theme.colorScheme.secondary
        : widget.inactiveThumbColor ?? theme.disabledColor;

    final borderRadius = widget.borderRadius ?? BorderRadius.circular(150);

    final elevationThumb = widget.enabled ? widget.elevationThumb : 0.0;

    final TextDirection currentDirection = Directionality.of(context);
    final bool isRTL = currentDirection == TextDirection.rtl;

    return AnimatedBuilder(
      animation: swipeAnimationController,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            // ignore: deprecated_member_use
            ..translate((isRTL ? -1 : 1) *
                swipeAnimationController.value *
                (constraints.maxWidth - widget.height)),
          child: Container(
            padding: widget.thumbPadding,
            child: GestureDetector(
              onHorizontalDragStart: _onHorizontalDragStart,
              onHorizontalDragUpdate: (details) =>
                  _onHorizontalDragUpdate(details, constraints.maxWidth),
              onHorizontalDragEnd: _onHorizontalDragEnd,
              child: Material(
                elevation: elevationThumb,
                borderRadius: borderRadius,
                color: thumbColor,
                clipBehavior: Clip.antiAlias,
                shadowColor: widget.thumbElevationColor,
                child: AnimatedBuilder(
                  animation: expandAnimationController,
                  builder: (context, child) {
                    return SizedBox(
                      width: widget.height +
                          (expandAnimationController.value *
                              (constraints.maxWidth - widget.height)) -
                          widget.thumbPadding.horizontal,
                      height: widget.height - widget.thumbPadding.vertical,
                      child: widget.thumb ??
                          Icon(
                            Icons.arrow_forward,
                            color: widget.activeTrackColor?.colors.first ??
                                widget.inactiveTrackColor?.colors.first,
                          ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    setState(() {
      swiped = false;
    });
    widget.onSwipeStart?.call();
  }

  bool hitEnd = false;

  void changeHitEnd(bool value, {bool vibrate = true}) {
    if (hitEnd == value) return;
    hitEnd = value;
    if (!vibrate) return;
    if (hitEnd == true) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, double width) {
    final TextDirection currentDirection = Directionality.of(context);
    final bool isRTL = currentDirection == TextDirection.rtl;
    final double offset = details.primaryDelta! / (width - widget.height);

    switch (widget._swipeButtonType) {
      case _SwipeButtonType.swipe:
        if (!swiped && widget.enabled) {
          if (isRTL) {
            swipeAnimationController.value -= offset;
          } else {
            swipeAnimationController.value += offset;
          }
        }
        break;
      case _SwipeButtonType.expand:
        if (!swiped && widget.enabled) {
          if (isRTL) {
            expandAnimationController.value -= offset;
          } else {
            expandAnimationController.value += offset;
          }
        }

        break;
    }
    if (swipeAnimationController.value == 1 ||
        expandAnimationController.value == 1) {
      changeHitEnd(true);
    } else {
      changeHitEnd(false);
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (swipeAnimationController.value == 1 ||
        expandAnimationController.value == 1) {
      setState(() {
        swiped = true;
        widget.onSwipe?.call();
      });
    }
    setState(() {
      swipeAnimationController.animateTo(0);
      expandAnimationController.animateTo(0);
    });
    widget.onSwipeEnd?.call();
    changeHitEnd(false, vibrate: false);
  }
}
