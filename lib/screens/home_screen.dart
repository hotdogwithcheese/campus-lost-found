import 'package:flutter/material.dart';
import 'feed_screen.dart'; // Import your feed screen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _navigateToMainFeed(BuildContext context) {
    // Replace HomeScreen with FeedScreen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const FeedScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/app_logo.png',
              width: 300,
              height: 150,
            ),
            const SizedBox(height: 40),
            const Text(
              'Campus Lost & Found',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Find what\'s lost. Return what\'s found.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 60),
            ElevatedButton.icon(
              onPressed: () => _navigateToMainFeed(context),
              icon: const Icon(Icons.arrow_forward_ios),
              label: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Continue to App Feed',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
