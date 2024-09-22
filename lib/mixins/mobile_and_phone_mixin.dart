import 'package:flutter/material.dart';

mixin MobileAndPhoneMixin<T extends StatefulWidget> on State<T> {
  final mobileController = TextEditingController();
  final phoneController = TextEditingController();

  Widget phoneField(
          {String hintText = "Phone",
          String labelText = "Phone",
          Function(String)? onChanged,
          String? Function(String?)? validator}) =>
      TextFormField(
        keyboardType: TextInputType.phone,
        validator: validator,
        onChanged: onChanged,
        controller: phoneController,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
        ),
      );
  Widget mobileFiled(
          {String hintText = "Mobile",
          String labelText = "Mobile",
          Function(String)? onChanged,
          String? Function(String?)? validator}) =>
      TextFormField(
        keyboardType: TextInputType.phone,
        validator: validator,
        onChanged: onChanged,
        controller: mobileController,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
        ),
      );
}
