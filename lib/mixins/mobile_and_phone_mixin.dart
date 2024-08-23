import 'package:flutter/material.dart';

mixin MobileAndPhoneMixin<T extends StatefulWidget> on State<T> {
  final mobileController = TextEditingController();
  final phoneController = TextEditingController();


  Widget get phoneField => TextFormField(
        controller: phoneController,
        decoration: const InputDecoration(
          hintText: "Phone",
        ),
      );

  Widget get mobileField => TextFormField(
        controller: mobileController,
        decoration: const InputDecoration(
          hintText: "Mobile",
        ),
      );
}



