// Path: lib/screens/post_item_screen.dart

import 'package:flutter/material.dart';

class PostItemScreen extends StatelessWidget {
  const PostItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Lost or Found Item'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Form development area. (Kyla needs to build the input fields here)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}