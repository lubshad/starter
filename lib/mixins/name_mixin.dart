import 'package:flutter/material.dart';
import 'package:get/utils.dart';

mixin NameMixin<T extends StatefulWidget> on State<T> {
  final nameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();

  Widget nameField({
    String? title = "Name",
    String? hintText,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) => TextFormField(
    onChanged: onChanged,
    controller: nameController,
    decoration: InputDecoration(hintText: hintText, labelText: title),
    validator:
        validator ??
        (value) => value == null || value.isEmpty ? "Name is required" : null,
  );

  Widget lastnameField({
    String? title = "Last Name",
    String? hintText = "Last Name",
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) => TextFormField(
    onChanged: onChanged,
    controller: lastnameController,
    decoration: InputDecoration(hintText: hintText, labelText: title),
    validator:
        validator ??
        (value) =>
            value == null || value.isEmpty ? "Last Name is required" : null,
  );

  Widget emailField({Function(String)? onChanged}) => TextFormField(
    onChanged: onChanged,
    controller: emailController,
    decoration: const InputDecoration(
      hintText: "Enter your email",

      label: Text("Email"),
    ),
    validator:
        (value) =>
            value == null || value.isEmpty
                ? "Email is required"
                : !value.isEmail
                ? "Please enter a valid email"
                : null,
  );
}
