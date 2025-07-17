// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/logger.dart';
import '../../splash_screen/splash_screen.dart';

mixin GoogleOauthMixin<T extends StatefulWidget> on State<T> {
  static List<String> scopes = <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ];

  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool buttonLoading = false;
  void makeButtonLoading() {
    buttonLoading = true;
    setState(() {});
  }

  void makeButtonNotLoading() {
    buttonLoading = false;
    setState(() {});
  }

  Future<void> signInWithGoogle() async {
    if (buttonLoading) return;
    makeButtonLoading();
    try {
      final GoogleSignInAccount googleSignInAccount = await _googleSignIn.authenticate();
      final authorizationClient = await googleSignInAccount.authorizationClient.authorizationForScopes(scopes);
      final GoogleSignInAuthentication googleSignInAuthentication = googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken:  authorizationClient?.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      makeButtonNotLoading();
      Navigator.pushNamedAndRemoveUntil(
          context, SplashScreen.path, (route) => false);
    } catch (error) {
      makeButtonNotLoading();
      logInfo(error);
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
