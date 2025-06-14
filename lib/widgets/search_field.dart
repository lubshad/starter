import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.hint,
    required this.controller,
    this.autofocus = false, 
  });

  final String hint;
  final TextEditingController controller;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: autofocus,
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              if (controller.text.isNotEmpty) {
                return GestureDetector(
                    onTap: () => controller.clear(),
                    child: const Icon(Icons.clear));
              }

              return const Icon(Icons.search);
            }),
      ),
    );
  }
}
