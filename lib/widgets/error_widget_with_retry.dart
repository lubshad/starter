import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import '../core/error_exception_handler.dart';
import '../exporter.dart';
import 'dio_exception_widget.dart';

class ErrorWidgetWithRetry extends StatelessWidget {
  const ErrorWidgetWithRetry({
    super.key,
    required this.exception,
    required this.retry,
  });

  final Exception exception;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) {
    Widget widget = Container();
    switch (exception.runtimeType) {
      case const (DioException):
        widget = DioExceptionWidget(exception: exception as DioException);
      case const (CustomException):
        widget = CustomExceptionWidget(exception: exception as CustomException);

      default:
        widget = Text(exception.toString(), textAlign: TextAlign.center);
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        widget,
        gapLarge,
        Material(
          color: Colors.transparent,
          shape: CircleBorder(),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFD41B5E),
                  Color(0xFFD51D5E),
                  Color(0xFFEE484E),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: InkWell(
              customBorder: CircleBorder(),
              onTap: retry,
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Icon(Icons.refresh, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomExceptionWidget extends StatelessWidget {
  const CustomExceptionWidget({super.key, required this.exception});

  final CustomException exception;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Builder(
            builder: (context) {
              if (exception.message is CustomExceptionType) {
                return (exception.message as CustomExceptionType)
                    .showErrorWidget
                    .animate(onPlay: (controller) => controller)
                    .move(duration: Duration(seconds: 4))
                    .move(duration: Duration(seconds: 4));
              }
              return SvgPicture.asset(
                    Assets.svgs.somethingWrong,
                    // ignore: deprecated_member_use
                    color: themeData.primaryColor,
                  )
                  .animate(onPlay: (controller) => controller)
                  .move(duration: Duration(seconds: 4))
                  .move(duration: Duration(seconds: 4));
            },
          ),
          gap,
          Text(
            exception.message.toString(),
            textAlign: TextAlign.center,
            style: context.bodyLarge.copyWith(fontSize: 18.sp),
          ),
        ],
      ),
    );
  }
}
