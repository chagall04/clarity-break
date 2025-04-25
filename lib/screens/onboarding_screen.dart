// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool _isLastPage = false;
  static const String _onboardingCompleteKey = 'onboardingComplete';

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPage({
    required Color color,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    return Container(
      color: color,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: theme.colorScheme.onPrimaryContainer),
          const SizedBox(height: 24),
          Text(title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(description,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _isLastPage = (i == 2)),
            children: [
              _buildPage(
                color: theme.colorScheme.primaryContainer.withOpacity(0.6),
                icon: Icons.refresh_rounded,
                title: "Reset Your Tolerance",
                description:
                "Regain sensitivity and rediscover your ideal experience with mindful breaks.",
              ),
              _buildPage(
                color: theme.colorScheme.secondaryContainer.withOpacity(0.6),
                icon: Icons.edit_note_outlined,
                title: "Track Your Journey",
                description:
                "Use the Journal for daily check-ins during breaks and track experiences afterward to gain insights.",
              ),
              _buildPage(
                color: theme.colorScheme.tertiaryContainer.withOpacity(0.6),
                icon: Icons.library_books_outlined,
                title: "Learn & Grow",
                description:
                "Explore the Library for tips, science, and strategies to make the most of your clarity breaks.",
              ),
            ],
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 3,
                effect: WormEffect(activeDotColor: theme.colorScheme.primary),
              ),
            ),
          ),
          if (_isLastPage)
            Positioned(
              bottom: 24,
              left: 40,
              right: 40,
              child: ElevatedButton(
                onPressed: _completeOnboarding,
                child: const Text("Get Started"),
              ),
            ),
        ],
      ),
    );
  }
}
