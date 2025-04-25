// lib/screens/splash_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import 'main_screen.dart';

const _onboardingCompleteKey = 'onboardingComplete';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goNext();
  }

  Future<void> _goNext() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool(_onboardingCompleteKey) ?? false;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => done ? const MainScreen() : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.asset(
            'assets/images/logo.png',
            height: 100,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.spa_outlined, size: 80, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 20),
          Text(
            "Clarity Break",
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
          ),
        ]),
      ),
    );
  }
}
