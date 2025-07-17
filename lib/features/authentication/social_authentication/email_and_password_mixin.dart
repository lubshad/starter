
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';

import '../../../core/app_config.dart';
import '../../../core/error_exception_handler.dart';
import '../../../core/repository.dart';
import '../../../services/shared_preferences_services.dart';
import '../../../services/snackbar_utils.dart';
import '../../profile_screen/common_controller.dart';
import '../../splash_screen/splash_screen.dart';
import 'otp_validation_screen.dart';

mixin EmailPasswordMixin<T extends StatefulWidget> on State<T> {
  bool loginButtonLoading = false;

  void makeLoginButtonLoading() {
    loginButtonLoading = true;
    setState(() {});
  }

  void makeLoginButtonNotLoading() {
    loginButtonLoading = false;
    setState(() {});
  }

  bool passwordVisible = false;
  IconData? get visibilityIcon => passwordVisible
      ? Icons.visibility_off_outlined
      : Icons.visibility_outlined;

  void touglePasswordVisibility() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  final TextEditingController domainController = TextEditingController(
    text:
        "${appConfig.scheme}://${appConfig.domain}${appConfig.port.isEmpty ? "" : ":${appConfig.port}"}",
  );
  final TextEditingController usernameController =
      TextEditingController(text: kDebugMode ? appConfig.username : "");
  final TextEditingController passwordController =
      TextEditingController(text: kDebugMode ? appConfig.password : "");

  final formKey = GlobalKey<FormState>(debugLabel: 'login_form_key');
  bool validate() {
    bool valid = false;
    if (!formKey.currentState!.validate()) {
      return valid;
    } else {
      valid = true;
    }
    return valid;
  }

  String? emailValidator(String? email) {
    return email!.isEmpty
        ? "Email is required"
        : email.isEmail
            ? null
            : "Please enter a valid email";
  }

  String? passwordValidator(String? password) {
    return password!.isEmpty
        ? "Password is required"
        : password.length < 3
            ? "Minimum 3 characters required"
            : null;
  }

  // Future<void> signInWithEmailAndPassword() async {
  //   if (!validate()) return;
  //   makeLoginButtonLoading();
  //   try {
  //     UserCredential userCredential =
  //         await FirebaseAuth.instance.signInWithEmailAndPassword(
  //       email: emailController.text,
  //       password: passwordController.text,
  //     );
  //     makeLoginButtonNotLoading();
  //     // Successfully signed in
  //     logInfo('Signed in: ${userCredential.user!.uid}');
  //     handleSignIn();
  //   } on FirebaseAuthException catch (e) {
  //     makeLoginButtonNotLoading();
  //     handleError(e);
  //   }
  // }

  String? validateUsername(String? value) {
    return value == null || value.isEmpty ? "Username is required" : null;
  }

  Future<void> signInWithEmailAndPassword() async {
    if (!validate()) return;
    makeLoginButtonLoading();
    DataRepository.i.setBaseUrl(domainController.text);
    DataRepository.i
        .login(
      username: usernameController.text,
      password: passwordController.text,
    )
        .then((token) async {
      makeLoginButtonNotLoading();
      await SharedPreferencesService.i
          .setValue(key: domainKey, value: domainController.text);
      await SharedPreferencesService.i.setValue(value: token);
      CommonController.i.init();
      handleSignIn();
    }).onError((error, stackTrace) {
      makeLoginButtonNotLoading();

      if ((error is CustomException) && error.statusCode == 403) {
        Navigator.pushNamed(context, OTPScreen.path, arguments: {
          "domain_url": domainController.text,
          "username": usernameController.text,
          "password": passwordController.text,
        });
      } else {
        showErrorMessage(error);
      }
    });
  }

  // Future<void> signUpWithEmailAndPassword() async {
  //   if (!validate()) return;
  //   makeLoginButtonLoading();
  //   try {
  //     UserCredential userCredential =
  //         await FirebaseAuth.instance.createUserWithEmailAndPassword(
  //       email: usernameController.text,
  //       password: passwordController.text,
  //     );
  //     makeLoginButtonNotLoading();
  //     // Successfully signed up
  //     logInfo('Signed up: ${userCredential.user!.uid}');
  //     handleSignIn();
  //   } on FirebaseAuthException catch (e) {
  //     makeLoginButtonNotLoading();
  //     logInfo(e.code);
  //     // Handle sign-up errors
  //     logInfo('Failed to sign up: $e');
  //   }
  // }

  String? passwordError;

  // void handleError(FirebaseAuthException e) {
  //   switch (e.code) {
  //     case "user-not-found":
  //       signUpWithEmailAndPassword();
  //       break;
  //     case "wrong-password":
  //       setState(() {
  //         passwordError = "Invalid Credentials";
  //       });
  //       break;
  //   }
  // }

  void handleSignIn() {
    Navigator.pushNamedAndRemoveUntil(
        context, SplashScreen.path, (route) => false);
  }
}
