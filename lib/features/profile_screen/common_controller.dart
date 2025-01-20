import 'package:flutter/material.dart';

import '../../core/repository.dart';
import '../../services/snackbar_utils.dart';
import 'profile_details_model.dart';

class CommonController extends ChangeNotifier {
  static CommonController get i => _instance;
  static final CommonController _instance = CommonController._private();

  CommonController._private();

  bool initialized = false;

  init() {
    if (initialized) return;
    fetchProfileDetails();
    initialized = true;
  }

  ProfileDetailsModel? profileDetails;

  fetchProfileDetails() {
    DataRepository.i.fetchProfileDetails().then(
      (value) {
        profileDetails = value;
        notifyListeners();
      },
    ).onError(
      (error, stackTrace) {
        showErrorMessage(error);
      },
    );
  }

 

  clear() {
    initialized = false;
  }
}
