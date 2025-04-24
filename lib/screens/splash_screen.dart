// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart'; // Splash screen package
import 'main_screen.dart'; // Import the main navigation screen

// Displays the splash screen on app startup
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access theme data

    // Use package for fade-in splash effect
    return FlutterSplashScreen.fadeIn(
      backgroundColor: theme.colorScheme.background, // Match app background
      duration: const Duration(milliseconds: 3000), // Display duration (3 seconds)
      onInit: () {
        debugPrint("Splash init"); // Optional: Log splash start
      },
      onEnd: () {
        debugPrint("Splash end"); // Optional: Log splash end
      },
      // Content displayed during splash
      childWidget: SizedBox(
        width: 200, // Constrain content size
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: Replace with Image.asset('assets/images/logo.png') when logo is ready
            Icon(
              Icons.spa_outlined, // Placeholder icon (wellness/clarity)
              size: 80.0,
              color: theme.colorScheme.primary, // Use primary theme color
            ),
            const SizedBox(height: 20), // Spacing
            Text(
              "Clarity Break", // App name
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary, // Use primary theme color
              ),
            ),
          ],
        ),
      ),
      // Screen to navigate to after splash duration
      nextScreen: const MainScreen(), // Navigate to the main app screen
    );
  }
}