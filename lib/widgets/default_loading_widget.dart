import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitChasingDots(
        // You can choose any other animation from the package
        color: Theme.of(context).primaryColor, // Customize the color
        size: 50.0, // Customize the size
      ),
    );
  }
}
