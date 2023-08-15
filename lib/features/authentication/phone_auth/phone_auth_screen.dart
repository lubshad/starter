import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

import '../../../constants.dart';
import '../../../core/logger.dart';
import '../../../screens/home_screen/home_screen.dart';
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
    if (!validate()) return;
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

  void validateOtp() async {
    if (!validate()) return;
    makeButtonLoading();
    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!, smsCode: pincodeController.text);
    // Sign the user in (or link) with the credential
    try {
      await auth.signInWithCredential(credential);
      Navigator.pushReplacementNamed(context, HomeScreen.path);
    } on FirebaseAuthException catch (e) {
      logInfo(e.code);
      if (e.code == 'invalid-verification-code') {
        otpErrorText = e.message;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(paddingLarge),
      child: Form(
          key: formKey,
          child: Builder(builder: (context) {
            if (!showOTP) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    keyboardType: TextInputType.number,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    validator: _validatePhone,
                    controller: _phoneController,
                    decoration: InputDecoration(
                      errorText: phoneErrorText,
                      prefixIcon: CountryCodePicker(
                        onChanged: _onCountryChanged,
                        initialSelection: _selectedCountry.name,
                      ),
                    ),
                  ),
                  gapLarge,
                  LoadingButton(
                    isLoading: buttonLoading,
                    onPressed: _sendOtp,
                    text: 'SEND OTP',
                  ),
                ],
              );
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Pinput(
                  errorText: otpErrorText,
                  controller: pincodeController,
                  length: otpLenth,
                  validator: pinValidation,
                ),
                gapLarge,
                LoadingButton(
                    isLoading: buttonLoading,
                    text: "VALIDATE OTP",
                    onPressed: validateOtp)
              ],
            );
          })),
    ));
  }

  void onCodeSent(String verId, int? forceToken) {
    setState(() {
      verificationId = verId;
      forceResendingToken = forceToken;
      buttonLoading = false;
      showOTP = true;
      formKey = GlobalKey<FormState>(debugLabel: "pincode");
    });
  }

  void onCodeAutoRetrievalTimeout(String verificationId) {}

  void onVerificationCompleted(PhoneAuthCredential credential) async {
    try {
      await auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      logInfo(e.code);
      switch (e.code) {
        case "value":
          break;
        default:
      }
    }
  }

  void onVerificationFailed(FirebaseAuthException error) {
    logInfo(error.code);
    switch (error.code) {
      case "invalid-phone-number":
        phoneErrorText = error.message;
    }
    makeButtonNotLoading();
  }
}
