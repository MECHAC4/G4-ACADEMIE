import 'package:flutter/material.dart';
import 'package:g4_academie/screens/auth_screen/welcome_screen.dart';
import 'package:g4_academie/theme/theme.dart';

import 'constants.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: lightMode,
      home: const WelcomeScreen(),
    );
  }
}
