import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const OneTripApp());
}

class OneTripApp extends StatelessWidget {
  const OneTripApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OneTrip',
      home: const LoginScreen(),
    );
  }
}