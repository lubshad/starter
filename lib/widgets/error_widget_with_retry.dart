
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../core/app_error.dart';
import 'dio_exception_widget.dart';

class ErrorWidgetWithRetry extends StatelessWidget {
  const ErrorWidgetWithRetry({
    super.key,
    required this.error,
    required this.retry,
  });

  final AppError error;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) {
    Widget widget = Container();
    switch (error.exception.runtimeType) {
      case DioException:
        widget = DioExceptionWidget(exception: error.exception);
      default:
        widget = Center(
          child: Column(
            children: [
              Text(error.exception.runtimeType.toString()),
              Text(error.message.toString()),
            ],
          ),
        );
    }
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget,
            TextButton(onPressed: retry, child: const Text("Retry")),
          ],
        ),
      ),
    );
  }
}
