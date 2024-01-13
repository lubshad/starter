// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../../core/repository.dart';
import '../../../exporter.dart';
import '../../../services/fcm_service.dart';
import '../../../services/shared_preferences_services.dart';
import '../../splash_screen/splash_screen.dart';

mixin FirebasePhoneAuthMixin<T extends StatefulWidget> on State<T> {
  String? verificationId;
  int? forceResendingToken;

  String? phoneErrorText;

  String? otpErrorText;

  void onCountryChanged(CountryCode value) {
    setState(() {
      selectedCountry = value;
    });
  }

  final phoneController = TextEditingController();
  CountryCode selectedCountry = CountryCode.fromDialCode("+91");

  String get phoneNumber {
    return (selectedCountry.dialCode ?? "") + phoneController.text;
  }

  FirebaseAuth auth = FirebaseAuth.instance;

  void sendOtp() async {
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

  String? validatePhone(String? value) {
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
    if (mounted) {
      setState(() {});
    }
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
      SharedPreferencesService.i.setValue(
          value:
              await FirebaseAuth.instance.currentUser?.getIdToken(true) ?? "");
      // await updateDevice();
      Navigator.pushNamedAndRemoveUntil(
          context, SplashScreen.path, (route) => false);
    } on FirebaseAuthException catch (e) {
      logInfo(e);
      if (e.code == 'invalid-verification-code') {
        otpErrorText = "OTP Entered is incorrect";
      }
    }
    makeButtonNotLoading();
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

  final ValueNotifier<Duration> stopwatchValue = ValueNotifier(Duration.zero);
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void dispose() {
    onScreen = false;
    stopwatchValue.dispose();
    super.dispose();
  }

  void _startStopwatch() {
    _stopwatch.start();
    stopwatchValue.value = _stopwatch.elapsed;
    _updateStopwatch();
  }

  void _resetStopwatch() {
    _stopwatch.stop();
    _stopwatch.reset();
    stopwatchValue.value = _stopwatch.elapsed;
  }

  bool onScreen = true;
  void _updateStopwatch() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_stopwatch.isRunning && !isTimeOut && onScreen) {
        stopwatchValue.value = _stopwatch.elapsed;
        _updateStopwatch();
      }
    });
  }

  PageController pageController = PageController();

  bool get isTimeOut {
    return stopwatchValue.value.inSeconds > 30;
  }

  int get timeRemaining {
    return isTimeOut ? 0 : 30 - stopwatchValue.value.inSeconds;
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
      SharedPreferencesService.i.setValue(
          value:
              await FirebaseAuth.instance.currentUser?.getIdToken(true) ?? "");
      // await updateDevice();
      Navigator.pushNamedAndRemoveUntil(
          context, SplashScreen.path, (route) => false);
    } on FirebaseAuthException catch (e) {
      logInfo(e);
      if (e.code == 'invalid-verification-code') {
        otpErrorText = "OTP Entered is incorrect";
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
    sendOtp();
  }

  Future updateDevice() async {
    final deviceInfo = await DeviceInfoPlugin().deviceInfo;
    final data = deviceInfo.data;
    data.addAll({"fcm_token": await FCMService.token});
    await DataRepository.i.updateDevice(deviceInfo);
  }
}



class FirebaseAuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    String token = SharedPreferencesService.i.getValue();
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      if (decodedToken.containsKey('exp')) {
        int expirationTimestamp = decodedToken['exp'];
        int currentTimestamp =
            DateTime.now().millisecondsSinceEpoch ~/ 1000; // Convert to seconds

        if (expirationTimestamp >= currentTimestamp) {
          logInfo("Token is still valid.");
        } else {
          logInfo("Token has expired.");
          // You might want to refresh the token here
          token =
              await FirebaseAuth.instance.currentUser?.getIdToken(true) ?? "";
          if (token != "") {
            SharedPreferencesService.i.setValue(value: token);
          }
        }
      } else {
        logInfo("Token does not have an expiration time.");
      }

      if (token != "") {
        options.headers.addAll({
          "Authorization": "Token $token",
        });
      }

      options.headers.addAll(
        {
          "X-App-Source": "Student",
          "User-Agent": Platform.isAndroid ? "ANDROID" : "IOS",
        },
      );
    } catch (e) {
      logInfo(e.toString());
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    switch (err.response?.statusCode) {
      case 401:
        break;
      default:
        break;
    }
    super.onError(err, handler);
  }
}
