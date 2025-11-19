import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase ONCE for the whole app
  await Supabase.initialize(
    url: 'https://sdozzwwrqtvsaoxpnbgh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkb3p6d3dycXR2c2FveHBuYmdoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMwNDMxOTksImV4cCI6MjA3ODYxOTE5OX0.24p5MYn4kXlYjPCtbq8nJa2sWofVilBa5wzrR4pIWBE',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lost and Found',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
