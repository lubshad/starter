import 'dart:async';

import 'package:flutter/material.dart';

mixin SearchMixin {
  Duration debouneDuration = const Duration(milliseconds: 500);
  Timer? debouncer;

  final searchController = TextEditingController();

  void addSearchListener(VoidCallback search) {
    searchController.addListener(() {
      debouncer?.cancel();
      debouncer = Timer(debouneDuration, () {
        search();
      });
    });
  }

  void removeSearchListener() {
    searchController.removeListener(() {});
    searchController.dispose();
  }
}
