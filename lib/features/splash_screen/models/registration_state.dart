

import 'package:get/utils.dart';

enum RegistrationState {
  basicDetails("Basic Details"),
  programSelection("Program Selection"),
  completed("Completed");

  final String value;
  const RegistrationState(this.value);

  static RegistrationState fromString(value) {
    return RegistrationState.values.firstWhereOrNull((element) =>
            value.toString().toLowerCase() == element.value.toLowerCase()) ??
        RegistrationState.basicDetails;
  }
}
