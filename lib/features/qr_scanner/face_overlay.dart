// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../../exporter.dart';

class FaceScanOverlay extends StatefulWidget {
  const FaceScanOverlay({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FaceScanOverlayState createState() => _FaceScanOverlayState();
}

class _FaceScanOverlayState extends State<FaceScanOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frameHeight = 1.sw * .8;
    final frameWidth = 1.sw * .7;

    return Stack(
      alignment: Alignment.center,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: FaceOverlayPainter(
                frameHeight: frameHeight,
                frameWidth: frameWidth,
              ),
            );
          },
        ),
        SizedBox(
          height: frameHeight,
          child: AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: _scanAnimation.value * (frameHeight - 4),
                  ),
                  child: Container(
                    width: frameWidth * 0.8,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xffD52358), Color(0xffEC7130)],
                        stops: const [0.2, 0.5],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xffEC7130),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(padding),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 200,
          left: 0,
          right: 0,
          child: Text(
            "Align your face within the frame",
            textAlign: TextAlign.center,
            style: context.bodySmall.copyWith(color: Colors.white),
          ),
        ),
        Positioned(
          bottom: 170,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'Make sure your face is clearly visible',
              style: context.bodyLarge.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class FaceOverlayPainter extends CustomPainter {
  final double frameWidth;
  final double frameHeight;
  FaceOverlayPainter({required this.frameWidth, required this.frameHeight});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withAlpha((255 * .2).toInt());

    final cutoutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: frameWidth,
      height: frameHeight,
    );

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(cutoutRect, const Radius.circular(20)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
