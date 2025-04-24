// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <<<=== IMPORT SharedPreferences
import 'screens/splash_screen.dart';
import 'providers/break_provider.dart';
import 'screens/main_screen.dart';
import 'services/notification_service.dart';
import 'screens/onboarding_screen.dart'; // <<<=== IMPORT OnboardingScreen

// Key for tracking onboarding completion in SharedPreferences
const String onboardingCompleteKey = 'onboardingComplete';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();

  // *** NEW: Check if onboarding is complete ***
  final prefs = await SharedPreferences.getInstance();
  final bool showOnboarding = !(prefs.getBool(onboardingCompleteKey) ?? false); // Show if key is null or false

  runApp(
    ChangeNotifierProvider(
      create: (context) => BreakProvider(),
      // *** Pass the showOnboarding flag to the app widget ***
      child: ClarityBreakApp(showOnboarding: showOnboarding),
    ),
  );
}

class ClarityBreakApp extends StatelessWidget {
  // *** NEW: Receive the flag ***
  final bool showOnboarding;
  const ClarityBreakApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    // --- ColorScheme and ThemeData definitions (Keep as they are) ---
    // [ Omitted for Brevity - Use the existing Theme/Color code ]
    final ColorScheme lightColorScheme = ColorScheme.fromSeed(/*...*/);
    final ColorScheme darkColorScheme = ColorScheme.fromSeed(/*...*/);
    ThemeData buildTheme(ColorScheme colorScheme, Brightness brightness) { /*...*/ return ThemeData(/*...*/); }


    // --- Root MaterialApp Widget ---
    return MaterialApp(
      title: 'Clarity Break',
      theme: buildTheme(lightColorScheme, Brightness.light),
      darkTheme: buildTheme(darkColorScheme, Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      // *** NEW: Decide initial screen based on flag ***
      home: showOnboarding ? const OnboardingScreen() : const SplashScreen(),
    );
  }
}