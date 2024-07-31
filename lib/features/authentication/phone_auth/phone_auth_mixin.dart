// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/app_config.dart';
import '../../../core/error_exception_handler.dart';
import '../../../core/interceptors.dart';
import '../../../core/repository.dart';
import '../../../core/universal_argument.dart';
import '../../../exporter.dart';
import '../../../main.dart';
import '../../../services/fcm_service.dart';
import '../../../services/shared_preferences_services.dart';
import '../../profile_screen/profile_screen.dart';
import '../../splash_screen/splash_screen.dart';

class PhoneAuthApiConstants {
  static String sendOtp = "send-otp";
  static String verifyOtp = "verify-otp";
}

class TokenAuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    String token = SharedPreferencesService.i.getValue();
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
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    switch (err.response?.statusCode) {
      case 401:
        signOut(navigatorKey.currentContext);
        break;
      default:
        break;
    }
    super.onError(err, handler);
  }
}

class PhoneAuthRepository with ErrorExceptionHandler {
  final Dio _client = Dio(BaseOptions(
    validateStatus: validateStatus,
    receiveDataWhenStatusError: true,
    baseUrl: "${appConfig.domain}/api/phone_authentication/",
    contentType: "application/json",
  ));

  PhoneAuthRepository._private() {
    // _client.interceptors.add(ErrorResolver());
    // _client.interceptors.add(AuthenticationInterceptor());
    _client.interceptors.add(LoggingInterceptor());
  }

  static PhoneAuthRepository get i => _instance;
  static final PhoneAuthRepository _instance = PhoneAuthRepository._private();

  Future<String> sendOtp(UniversalArgument data) async {
    try {
      final response =
          await _client.post(PhoneAuthApiConstants.sendOtp, data: data.toMap());
      return response.data as String;
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<String> verifyOtp(Map<String, String?> map) async {
    try {
      final response =
          await _client.post(PhoneAuthApiConstants.verifyOtp, data: map);
      return response.data as String;
    } catch (e) {
      throw handleError(e);
    }
  }
}

mixin PhoneAuthMixin<T extends StatefulWidget> on State<T> {
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

  void sendOtp() async {
    clearErrors();
    if (pageController.page == 0 && !validate()) return;
    makeButtonLoading();
    PhoneAuthRepository.i
        .sendOtp(UniversalArgument(text: phoneNumber))
        .then((value) {
      onCodeSent(value, 1);
    }).onError((error, stackTrace) {
      phoneErrorText = error.toString();
      makeButtonNotLoading();
    });
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
    PhoneAuthRepository.i.verifyOtp({
      "text": verificationId,
      "otp": pincodeController.text
    }).then((value) async {
      SharedPreferencesService.i.setValue(value: value);
      // await updateDevice();
      makeButtonNotLoading();
      Navigator.pushNamedAndRemoveUntil(
          context, SplashScreen.path, (route) => false);
    }).onError((error, stackTrace) {
      otpErrorText = error.toString();
      makeButtonNotLoading();
    });
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

  void clearErrors() {
    FocusScope.of(context).unfocus();
    otpErrorText = null;
    phoneErrorText = null;
    setState(() {});
  }
}
