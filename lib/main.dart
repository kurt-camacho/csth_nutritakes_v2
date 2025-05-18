import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Adjust import based on your project structure

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriTakes',
      theme: ThemeData(primarySwatch: Colors.green),
      home:
          HomeScreen(), // <-- No const here if HomeScreen constructor is not const
    );
  }
}
