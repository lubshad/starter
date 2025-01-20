// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../../../core/repository.dart';
import '../../../exporter.dart';
import '../../../services/shared_preferences_services.dart';
import '../../../services/snackbar_utils.dart';
import '../../../widgets/loading_button.dart';
import '../../navigation/navigation_screen.dart';
import '../../profile_screen/common_controller.dart';
import 'social_authentication_screen.dart';

class OTPScreen extends StatefulWidget {
  static const String path = "/otp-validation-screen";
  const OTPScreen({
    super.key,
    required this.username,
    required this.password,
    required this.domainUrl,
  });

  final String username;
  final String password;
  final String domainUrl;

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  final formKey = GlobalKey<FormState>(debugLabel: 'otp_form_key');
  bool validate() {
    bool valid = false;
    if (!formKey.currentState!.validate()) {
      return valid;
    } else {
      valid = true;
    }
    return valid;
  }

  bool donotAsk = false;

  bool buttonLoading = false;
  makeButtonLoading() {
    buttonLoading = true;
    setState(() {});
  }

  makeButtonNotLoading() {
    buttonLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Color.fromRGBO(30, 60, 87, 1);

    const defaultPinTheme = PinTheme(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: dividerColor,
            ),
          ),
        ),
        textStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 24,
        ));

    final cursor = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 56,
          height: 3,
          decoration: BoxDecoration(
            color: borderColor,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
    final preFilledWidget = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 56,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
    return Scaffold(
      extendBodyBehindAppBar: true,
      // resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: primaryColor,
          ),
          LoginBackground(assetImage: Assets.svgs.otpBackground),
          LoginBottomSheet(
              child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Two-factor Authentication",
                  style: context.labelLarge,
                ),
                gap,
                Text(
                  "Enter the verification code generated in your authenticator app",
                  style: context.labelLarge.copyWith(
                    color: const Color(
                      0xff6E6E6E,
                    ),
                  ),
                ),
                gap,
                Pinput(
                  autofocus: true,
                  length: 6,
                  pinAnimationType: PinAnimationType.slide,
                  controller: controller,
                  focusNode: focusNode,
                  defaultPinTheme: defaultPinTheme,
                  showCursor: true,
                  cursor: cursor,
                  preFilledWidget: preFilledWidget,
                  validator: (value) =>
                      value == null || value.isEmpty || value.length != 6
                          ? "Enter your 6 digit OTP"
                          : null,
                ),
                gapXL,
                LoadingButton(
                    buttonLoading: buttonLoading,
                    text: "Submit".toUpperCase(),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      makeButtonLoading();
                      DataRepository.i
                          .login(
                        username: widget.username,
                        password: widget.password,
                        totp: controller.text,
                        donotAsk: true,
                      )
                          .then(
                        (value) async {
                          makeButtonNotLoading();
                          await SharedPreferencesService.i.setValue(
                              key: domainKey, value: widget.domainUrl);
                          await SharedPreferencesService.i
                              .setValue(value: value);
                          CommonController.i.init();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            NavigationScreen.path,
                            (route) => false,
                          );
                        },
                      ).onError(
                        (error, stackTrace) {
                          makeButtonNotLoading();
                          showErrorMessage(error.toString());
                        },
                      );
                    }),
              ],
            ),
          ))
        ],
      ),
    );
  }
}
