import 'package:flutter/material.dart';

void main() {
  // Sets up the main function to run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Ensure the app uses Material Design, as specified in pubspec.yaml
      home: Scaffold(
        body: Center(
          // This is the required placeholder text for the milestone
          child: Text(
            "Home Screen - Coming in Week 3",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
    );
  }
}