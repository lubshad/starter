import 'package:flutter/material.dart';
import 'package:get/utils.dart';

mixin NameMixin<T extends StatefulWidget> on State<T> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  Widget nameField(

          {String? title,
          String? hintText, 
          Function(String)? onChanged,
          String? Function(String?)? validator}) =>
      TextFormField(
        onChanged: onChanged,
        controller: nameController,
        decoration: InputDecoration(
          hintText: hintText,
          label: Text(title ?? "Name"),
        ),
        validator: validator ??
            (value) =>
                value == null || value.isEmpty ? "Name is required" : null,
      );

  Widget emailField({
    Function(String)? onChanged,
    String? hintText = "Enter your email",
    String? labelText = "Email",
    String? Function(String?)? validator,
  }) => TextFormField(
    onChanged: onChanged,
    controller: emailController,
    decoration: InputDecoration(hintText: hintText, labelText: labelText),
    validator:
        validator ??
        (value) => value == null || value.isEmpty
            ? "Email is required"
            : !value.isEmail
            ? "Please enter a valid email"
            : null,
  );
}
