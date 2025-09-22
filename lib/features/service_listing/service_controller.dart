import 'package:flutter/material.dart';
import 'package:starter/models/name_id.dart';

class ServiceController extends ChangeNotifier {
  List<NameId> services = [];

  ServiceController._private() {
    // DataRepository.i.fetchBusinessServices(pageSize: 100, page: 1).then((
    //   value,
    // ) {
    //   services = value.results;
    //   notifyListeners();
    // });
  }

  List<NameId> selectedServices = [];

  void tougleServiceSelection(NameId service) {
    if (selectedServices.contains(service)) {
      selectedServices.remove(service);
    } else {
      selectedServices.add(service);
    }
    notifyListeners();
  }

  static final _instance = ServiceController._private();
  static ServiceController get i => _instance;
}
