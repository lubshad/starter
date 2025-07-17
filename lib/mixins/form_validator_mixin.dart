// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import '../exporter.dart';
import '../main.dart';
import '../widgets/common_sheet.dart';
import '../widgets/loading_button.dart';

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
              onPressed: () => Navigator.maybePop(context, true))
        ],
      ));

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
      Navigator.pop(
        context,
        true,
      );
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
      tougleScroll();
    }
    return valid;
  }

  void tougleScroll() {
    if (!formScrollController.hasClients) return;
    if (atBottom()) {
      scrollToTop();
    } else {
      scrollToBottom();
    }
  }

  bool atBottom() {
    if (!formScrollController.hasClients) return false;
    if (formScrollController.position.pixels ==
        formScrollController.position.maxScrollExtent) {
      return true;
    }
    return false;
  }

  void scrollToTop() {
    if (!formScrollController.hasClients) return;
    formScrollController.animateTo(
      0,
      duration: animationDuration,
      curve: Curves.fastOutSlowIn,
    );
  }

  void scrollToBottom() {
    if (!formScrollController.hasClients) return;
    formScrollController.animateTo(
      formScrollController.position.maxScrollExtent,
      duration: animationDuration,
      curve: Curves.fastOutSlowIn,
    );
  }
}
