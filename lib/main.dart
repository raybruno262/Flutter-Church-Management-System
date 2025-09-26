import 'package:flutter/material.dart';
import 'package:flutter_churchcrm_system/constants.dart';
import 'package:flutter_churchcrm_system/screens/login.dart';
import 'package:flutter_churchcrm_system/screens/otpverification.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Church CRM System',
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundcolor,
        brightness: Brightness.dark,
      ),
      home: const LoginScreen(),
    );
  }
}
