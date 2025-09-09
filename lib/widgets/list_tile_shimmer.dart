import 'package:flutter/material.dart';

import '../exporter.dart';
import 'shimwrapper.dart';

class ListTileShimmer extends StatelessWidget {
  const ListTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:
          Shimwrapper(child: AspectRatio(aspectRatio: 1, child: Container())),
      title: Shimwrapper(
          child: SizedBox(width: 1.sw * .5, child: Text("Title"))),
      subtitle: Shimwrapper(child: Text("Subtitle")),
    );
  }
}