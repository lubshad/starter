import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../authentication/phone_auth/phone_auth_screen.dart';
import '../profile_screen/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String path = "/home";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user == null) {
        Navigator.pushReplacementNamed(context, PhoneVerification.path);
      } else {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      drawer: ProfileScreen(),
    );
  }
}
