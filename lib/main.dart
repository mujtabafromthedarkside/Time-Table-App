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
      theme: ThemeData(
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.white), // Set your desired default text color
          bodyText2: TextStyle(color: Colors.white), // You can set different styles for other text types if needed
        ),
      ),
      title: 'Time Table',
      debugShowCheckedModeBanner: false,
      home: const LandingPage(),
    );
  }
}