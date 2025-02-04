import 'package:flutter/material.dart';

import '../../core/repository.dart';
import '../../exporter.dart';
import '../../mixins/form_validator_mixin.dart';
import '../../mixins/mobile_and_phone_mixin.dart';
import '../../mixins/name_mixin.dart';
import '../../services/snackbar_utils.dart';
import '../../widgets/bottom_button_padding.dart';
import '../../widgets/loading_button.dart';
import '../profile_screen/common_controller.dart';

class UpdateProfileScreen extends StatefulWidget {
  static const String path = "/update-profile";
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen>
    with
        FormValidatorMixin,
        NameMixin,
        // JobPositionEmailMixin,
        MobileAndPhoneMixin {
  @override
  void initState() {
    super.initState();
    nameController.text = CommonController.i.profileDetails?.name ?? "";
    phoneController.text = CommonController.i.profileDetails?.phone ?? "";
    emailController.text = CommonController.i.profileDetails?.email ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: onFormPopInvoked,
      child: Scaffold(
        appBar: AppBar(title: Text("Update Profile")),
        bottomNavigationBar: BottomButtonPadding(
          child: LoadingButton(
              buttonLoading: buttonLoading, text: "Update", onPressed: submit),
        ),
        body: SingleChildScrollView(
          controller: formScrollController,
          padding: const EdgeInsets.symmetric(
            horizontal: padding,
            vertical: padding,
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                gapLarge,
                const Center(child: Placeholder()),
                gapXL,
                nameField(
                  onChanged: (p0) {
                    makeDataChanged();
                  },
                ),
                phoneField(
                  onChanged: (p0) {
                    makeDataChanged();
                  },
                ),
                emailField(
                  onChanged: (p0) {
                    makeDataChanged();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void submit() {
    if (!validate()) return;
    makeButtonLoading();
    DataRepository.i
        .updateProfileDetails(CommonController.i.profileDetails!.copyWith(
      phone: phoneController.text,
      email: emailController.text,
      name: nameController.text,
    ))
        .then(
      (value) {
        makeButtonNotLoading();
        dataChanged = false;
        showSuccessMessage(value.message);
        CommonController.i.fetchProfileDetails();
      },
    ).onError(
      (error, stackTrace) {
        makeButtonNotLoading();
      },
    );
  }
}
