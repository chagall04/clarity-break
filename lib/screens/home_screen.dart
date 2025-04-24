import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder content for the Home screen
    return const Scaffold(
      // We might not need an AppBar here if MainScreen provides one
      // appBar: AppBar(title: Text('Home')),
      body: Center(
        child: Text(
          'Home Screen - Break Status Here',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}