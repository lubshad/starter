import 'package:flutter/material.dart';
import 'package:starter/extensions.dart';
import 'package:starter/theme/theme.dart';


import '../../../constants.dart';

class ChatDateSeperatorItem extends StatelessWidget {
  final DateTime date;
  const ChatDateSeperatorItem({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final label = date.dateFormat(year: true) ?? "";
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: Material(
          shadowColor: Colors.black26,
          color: Colors.white,
          elevation: 1.0,

          child: Padding(
            padding: const EdgeInsets.all(padding),
            child: Text(label, style: context.bodySmall),
          ),
        ),
      ),
    );
  }
}
