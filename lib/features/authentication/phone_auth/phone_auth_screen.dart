import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pinput/pinput.dart';
import 'package:starter/core/theme.dart';
import 'package:starter/gen/assets.gen.dart';
import 'package:starter/theme/t_style.dart';

import '../../../constants.dart';
import '../../../core/logger.dart';
import '../../screens/home_screen/home_screen.dart';
import '../../../widgets/loading_button.dart';

class PhoneVerification extends StatefulWidget {
  static const String path = "/phone-verification";

  const PhoneVerification({super.key});

  @override
  State<PhoneVerification> createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  String? verificationId;
  ConfirmationResult? confirmationResult;

  int? forceResendingToken;

  bool showOTP = false;

  String? phoneErrorText;

  String? otpErrorText;

  void _onCountryChanged(CountryCode value) {
    setState(() {
      _selectedCountry = value;
    });
  }

  final _phoneController = TextEditingController();
  CountryCode _selectedCountry = CountryCode.fromDialCode("+91");

  String get phoneNumber {
    return (_selectedCountry.dialCode ?? "") + _phoneController.text;
  }

  FirebaseAuth auth = FirebaseAuth.instance;

  void _sendOtp() async {
    if (pageController.page == 0 && !validate()) return;
    makeButtonLoading();
    await auth.verifyPhoneNumber(
      timeout: const Duration(seconds: 30),
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
    );
  }

  String? _validatePhone(String? value) {
    return value!.isEmpty
        ? "Phone is required"
        : value.length < 7
            ? "Please enter a valid number"
            : null;
  }

  bool buttonLoading = false;
  makeButtonLoading() {
    setState(() {
      buttonLoading = true;
    });
  }

  makeButtonNotLoading() {
    buttonLoading = false;
    setState(() {});
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>(debugLabel: 'phone');
  bool validate() {
    bool valid = false;
    if (!formKey.currentState!.validate()) {
      return valid;
    } else {
      valid = true;
    }
    return valid;
  }

  GlobalKey<FormState> pinformKey = GlobalKey<FormState>(debugLabel: 'phone');
  bool validatepin() {
    bool valid = false;
    if (!pinformKey.currentState!.validate()) {
      return valid;
    } else {
      valid = true;
    }
    return valid;
  }

  void validateOtp() async {
    if (!validatepin()) return;
    makeButtonLoading();
    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!, smsCode: pincodeController.text);
    // Sign the user in (or link) with the credential
    try {
      await auth.signInWithCredential(credential);
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, HomeScreen.path);
    } on FirebaseAuthException catch (e) {
      logInfo(e);
      if (e.code == 'invalid-verification-code') {
        otpErrorText = "OTP Entered is incorrect";
      }
      makeButtonNotLoading();
    }
  }

  final pincodeController = TextEditingController();

  int otpLenth = 6;

  String? pinValidation(String? value) {
    return value!.isEmpty
        ? "OTP is required"
        : value.length < otpLenth
            ? "Please enter a valid otp"
            : null;
  }

  final ValueNotifier<Duration> _stopwatchValue = ValueNotifier(Duration.zero);
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void dispose() {
    _stopwatchValue.dispose();
    super.dispose();
  }

  void _startStopwatch() {
    _stopwatch.start();
    _stopwatchValue.value = _stopwatch.elapsed;
    _updateStopwatch();
  }

  // void _stopStopwatch() {
  //   _stopwatch.stop();
  // }

  void _resetStopwatch() {
    _stopwatch.stop();
    _stopwatch.reset();
    _stopwatchValue.value = _stopwatch.elapsed;
  }

  void _updateStopwatch() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_stopwatch.isRunning && !isTimeOut) {
        _stopwatchValue.value = _stopwatch.elapsed;
        _updateStopwatch();
      }
    });
  }

  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: Builder(builder: (context) {
            return PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: pageController,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(paddingXL),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            keyboardType: TextInputType.number,
                            autofillHints: const [
                              AutofillHints.telephoneNumber
                            ],
                            validator: _validatePhone,
                            controller: _phoneController,
                            decoration: InputDecoration(
                              hintText: "Enter Phone Number",
                              errorText: phoneErrorText,
                              prefixIcon: CountryCodePicker(
                                onChanged: _onCountryChanged,
                                initialSelection: _selectedCountry.name,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "By continuing, you agree  to our Terms of Uses and Privacy policy ",
                            style: Tstyle.labelLarge,
                            textAlign: TextAlign.center,
                          ),
                          gapLarge,
                          LoadingButton(
                            isLoading: buttonLoading,
                            onPressed: _sendOtp,
                            text: 'Next',
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(paddingXL),
                    child: Form(
                      key: pinformKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          Pinput(
                            forceErrorState: otpErrorText != null,
                            errorText: otpErrorText,
                            controller: pincodeController,
                            length: otpLenth,
                            validator: pinValidation,
                          ),
                          if (isTimeOut)
                            IconButton(
                              icon: SvgPicture.asset(Assets.svgs.retry),
                              onPressed: resendOtp,
                            ),
                          const Spacer(),
                          RichText(
                            text: TextSpan(children: [
                              WidgetSpan(
                                  child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Change ",
                                    style: Tstyle.labelLarge,
                                  ),
                                  TextButton(
                                      style: shrinkedButton,
                                      onPressed: () =>
                                          pageController.animateToPage(0,
                                              duration: animationDuration,
                                              curve: Curves.fastOutSlowIn),
                                      child: Text(phoneNumber)),
                                ],
                              )),
                              WidgetSpan(
                                  child: AnimatedBuilder(
                                      animation: _stopwatchValue,
                                      builder: (context, child) {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            TextButton(
                                                onPressed: isTimeOut
                                                    ? resendOtp
                                                    : null,
                                                style: shrinkedButton,
                                                child:
                                                    const Text("Resend OTP ")),
                                            if (!isTimeOut)
                                              Text("in $timeRemaining seconds",
                                                  style: Tstyle.labelLarge),
                                          ],
                                        );
                                      })),
                            ]),
                          ),
                          gapXL,
                          LoadingButton(
                              isLoading: buttonLoading,
                              text: "Validate",
                              onPressed: validateOtp)
                        ],
                      ),
                    ),
                  ),
                ]);
          }),
        ));
  }

  bool get isTimeOut {
    return _stopwatchValue.value.inSeconds > 30;
  }

  int get timeRemaining {
    return isTimeOut ? 0 : 30 - _stopwatchValue.value.inSeconds;
  }

  void onCodeSent(String verId, int? forceToken) {
    setState(() {
      verificationId = verId;
      forceResendingToken = forceToken;
      buttonLoading = false;
    });

    _resetStopwatch();
    _startStopwatch();
    if (pageController.page != 1) {
      pageController.nextPage(
          duration: animationDuration, curve: Curves.fastOutSlowIn);
    }
  }

  void onCodeAutoRetrievalTimeout(String verificationId) {}

  void onVerificationCompleted(PhoneAuthCredential credential) async {
    try {
      await auth.signInWithCredential(credential);
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, HomeScreen.path);
    } on FirebaseAuthException catch (e) {
      logInfo(e);
      switch (e.code) {
        case "value":
          break;
        default:
      }
    }
  }

  void onVerificationFailed(FirebaseAuthException error) {
    logInfo(error);
    switch (error.code) {
      case "invalid-phone-number":
        phoneErrorText = error.message;
    }
    makeButtonNotLoading();
  }

  void resendOtp() {
    pincodeController.clear();
    _sendOtp();
  }
}
