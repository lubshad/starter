import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'default_loading_widget.dart';

class NetworkResource<T> extends StatelessWidget {
  const NetworkResource(
    this.future, {
    super.key,
    this.loading = const LoadingWidget(),
    required this.error,
    required this.success,
  });

  final Future<T>? future;
  final Widget loading;
  final Widget Function(dynamic) error;
  final Widget Function(T) success;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (future == null) return loading;
        Widget widget = Container();
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            widget = loading;
            break;
          case ConnectionState.done:
            if (snapshot.hasError) {
              widget = error(snapshot.error);
            } else if (snapshot.hasData) {
              widget = success(snapshot.data as T);
            }
            break;
          default:
        }
        return widget.animate().fadeIn();
      },
    );
  }
}
