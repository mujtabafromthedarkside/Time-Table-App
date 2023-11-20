import 'package:flutter/material.dart';
import 'screens/LandingPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign Saathi',
      home: const LandingPage(),
    );
  }
}

