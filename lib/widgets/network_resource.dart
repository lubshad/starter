import 'package:flutter/material.dart';

import 'default_loading_widget.dart';

class NetworkResource<Type> extends StatelessWidget {
  const NetworkResource(this.future,
      {super.key,
      this.loading = const LoadingWidget(),
      required this.error,
      required this.success});

  final Future<Type>? future;
  final Widget loading;
  final Widget Function(dynamic) error;
  final Widget Function(Type) success;

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
              widget = success(snapshot.data as Type);
            }
            break;
          default:
        }
        return widget;
      },
    );
  }
}
