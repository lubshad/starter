
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';

import '../../../exporter.dart';
import '../../splash_screen/splash_screen.dart';

mixin EmailPasswordMixin<T extends StatefulWidget> on State<T> {
  bool loginButtonLoading = false;
  makeLoginButtonLoading() {
    loginButtonLoading = true;
    setState(() {});
  }

  makeLoginButtonNotLoading() {
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

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
        : password.length < 6
            ? "Minimum 6 characters required"
            : null;
  }

  Future<void> signInWithEmailAndPassword() async {
    if (!validate()) return;
    makeLoginButtonLoading();
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      makeLoginButtonNotLoading();
      // Successfully signed in
      logInfo('Signed in: ${userCredential.user!.uid}');
      handleSignIn();
    } on FirebaseAuthException catch (e) {
      makeLoginButtonNotLoading();
      handleError(e);
    }
  }

  Future<void> signUpWithEmailAndPassword() async {
    if (!validate()) return;
    makeLoginButtonLoading();
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      makeLoginButtonNotLoading();
      // Successfully signed up
      logInfo('Signed up: ${userCredential.user!.uid}');
      handleSignIn();
    } on FirebaseAuthException catch (e) {
      makeLoginButtonNotLoading();
      logInfo(e.code);
      // Handle sign-up errors
      logInfo('Failed to sign up: $e');
    }
  }

  String? passwordError;

  void handleError(FirebaseAuthException e) {
    switch (e.code) {
      case "user-not-found":
        signUpWithEmailAndPassword();
        break;
      case "wrong-password":
        setState(() {
          passwordError = "Invalid Credentials";
        });
        break;
    }
  }

  void handleSignIn() {
    Navigator.pushNamedAndRemoveUntil(
        context, SplashScreen.path, (route) => false);
  }
}
