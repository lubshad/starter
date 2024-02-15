// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/logger.dart';
import '../../splash_screen/splash_screen.dart';

mixin GoogleOauthMixin<T extends StatefulWidget> on State<T> {
  // static List<String> scopes = <String>[
  //   'email',
  //   'https://www.googleapis.com/auth/contacts.readonly',
  // ];

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
      // scopes: scopes,
      );

  bool buttonLoading = false;
  makeButtonLoading() {
    buttonLoading = true;
    setState(() {});
  }

  makeButtonNotLoading() {
    buttonLoading = false;
    setState(() {});
  }

  Future signInWithGoogle() async {
    if (buttonLoading) return;
    makeButtonLoading();
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      FirebaseAuth.instance.signInWithCredential(credential);
      makeButtonNotLoading();
      Navigator.pushNamedAndRemoveUntil(
          context, SplashScreen.path, (route) => false);
    } catch (error) {
      makeButtonNotLoading();
      logInfo(error);
    }
  }

  static signOut() {
    _googleSignIn.signOut().then((value) {
      value?.clearAuthCache();
    });
  }
}
