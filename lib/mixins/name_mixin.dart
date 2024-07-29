import 'package:flutter/material.dart';

mixin NameMixin<T extends StatefulWidget> on State<T> {
  final nameController = TextEditingController();
  

    Widget nameField({String? title}) =>  TextFormField(
          controller: nameController,
          decoration:  InputDecoration(
            hintText: title ?? "Name",
          ),
          validator: (value) =>
              value == null || value.isEmpty ? "Name is required" : null,
        );
}
