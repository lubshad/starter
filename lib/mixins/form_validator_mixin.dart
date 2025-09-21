// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import '../exporter.dart';
import '../main.dart';
import '../widgets/common_sheet.dart';
import '../widgets/loading_button.dart';

/// A mixin that provides form validation and scrolling functionality.
///
/// Usage:
/// 1. Add GlobalKeys for your form fields
/// 2. Add the keys to formFieldKeys list using addFormFieldKey() or addFormFieldKeys()
/// 3. Call validate() to validate the form and automatically scroll to first error
///
/// Example:
/// ```dart
/// class MyFormScreen extends StatefulWidget {
///   @override
///   State<MyFormScreen> createState() => _MyFormScreenState();
/// }
///
/// class _MyFormScreenState extends State<MyFormScreen> with FormValidatorMixin {
///   final GlobalKey _nameKey = GlobalKey();
///   final GlobalKey _emailKey = GlobalKey();
///
///   @override
///   void initState() {
///     super.initState();
///     addFormFieldKeys([_nameKey, _emailKey]);
///   }
///
///   void onSubmit() {
///     if (validate()) {
///       // Form is valid, proceed with submission
///     }
///     // If invalid, form will automatically scroll to first error
///   }
/// }
/// ```
mixin FormValidatorMixin<T extends StatefulWidget> on State<T> {
  bool buttonLoading = false;
  void makeButtonLoading() {
    buttonLoading = true;
    setState(() {});
  }

  void makeButtonNotLoading() {
    buttonLoading = false;
    setState(() {});
  }

  String debugLabel = "form_key_debug_label";

  // List of GlobalKeys for form fields to enable scrolling to first error
  List<GlobalKey> formFieldKeys = [];

  /// Helper method to add form field keys for scrolling to first error
  void addFormFieldKey(GlobalKey key) {
    if (!formFieldKeys.contains(key)) {
      formFieldKeys.add(key);
    }
  }

  /// Helper method to add multiple form field keys at once
  void addFormFieldKeys(List<GlobalKey> keys) {
    for (final key in keys) {
      addFormFieldKey(key);
    }
  }

  Widget discardBottomSheet(BuildContext context) => CommonBottomSheet(
    title: "Discard Changes",
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        gapXXL,
        const Row(),
        const Text("Are you sure want to discard the changes"),
        gapXL,
        LoadingButton(
          buttonLoading: false,
          text: "Discard",
          onPressed: () => Navigator.maybePop(context, true),
        ),
      ],
    ),
  );

  Future<void> onFormPopInvoked(bool didPop, dynamic result) async {
    if (didPop) return;
    if (dataChanged) {
      final result = await showModalBottomSheet(
        context: navigatorKey.currentContext!,
        builder: (context) => discardBottomSheet(context),
      );
      if (result == null) return;
      if (!mounted) return;
      Navigator.pop(context);
    } else {
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  bool dataChanged = false;

  void makeDataChanged() {
    dataChanged = true;
  }

  ScrollController formScrollController = ScrollController();

  @override
  initState() {
    super.initState();
    formKey = GlobalKey<FormState>(debugLabel: debugLabel);
  }

  GlobalKey<FormState>? formKey;
  bool validate() {
    if (formKey == null) return false;
    bool valid = false;
    if (!formKey!.currentState!.validate()) {
    } else {
      valid = true;
    }
    if (!valid) {
      scrollToFirstError();
    }
    return valid;
  }

  /// Scrolls to the first form field that has a validation error
  void scrollToFirstError() {
    if (!formScrollController.hasClients || formFieldKeys.isEmpty) return;

    // Use a post-frame callback to ensure the validation errors are rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToFirstErrorField();
    });
  }

  void _scrollToFirstErrorField() {
    if (!formScrollController.hasClients || formFieldKeys.isEmpty) return;

    // Find the first field with an error by checking each field's validation state
    for (final fieldKey in formFieldKeys) {
      final context = fieldKey.currentContext;
      if (context != null) {
        // Check if this field has a validation error by looking for error text
        final widget = context.widget;
        if (widget is TextFormField) {
          // Get the current value and run the validator to check for errors
          final controller = widget.controller;
          if (controller != null) {
            final validator = widget.validator;
            if (validator != null) {
              final errorText = validator(controller.text);
              if (errorText != null && errorText.isNotEmpty) {
                // This field has an error, scroll to it
                Scrollable.ensureVisible(
                  context,
                  duration: animationDuration,
                  curve: Curves.fastOutSlowIn,
                  alignment: 0.3, // Position field in upper third of viewport
                );
                return; // Exit after scrolling to the first field with error
              }
            }
          }
        }
      }
    }

    // If no field with error found, scroll to the first field as fallback
    final firstFieldKey = formFieldKeys.first;
    final context = firstFieldKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: animationDuration,
        curve: Curves.fastOutSlowIn,
        alignment: 0.3,
      );
    }
  }

  /// Alternative method that scrolls to the first field in the formFieldKeys list
  /// This is useful when you want to scroll to the first field regardless of error state
  void scrollToFirstField() {
    if (!formScrollController.hasClients || formFieldKeys.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToFirstField();
    });
  }

  void _scrollToFirstField() {
    if (!formScrollController.hasClients || formFieldKeys.isEmpty) return;

    final firstFieldKey = formFieldKeys.first;
    final context = firstFieldKey.currentContext;
    if (context != null) {
      // Use Scrollable.ensureVisible to bring the field into view
      Scrollable.ensureVisible(
        context,
        duration: animationDuration,
        curve: Curves.fastOutSlowIn,
        alignment:
            0.3, // Position field in upper third of viewport for consistency
      );
    }
  }
}
