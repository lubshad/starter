import 'package:flutter/material.dart';

mixin MobileAndPhoneMixin<T extends StatefulWidget> on State<T> {
  final mobileController = TextEditingController();
  final phoneController = TextEditingController();

  Widget phoneField({
    String hintText = "Phone",
    String labelText = "Phone",
    Function(String)? onChanged
  }) =>
      TextFormField(
        onChanged: onChanged,
        controller: phoneController,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
        ),
      );

  Widget get mobileField => TextFormField(
        controller: mobileController,
        decoration: const InputDecoration(
            hintText: "Mobile Number", label: Text("Mobile Number")),
      );
}
