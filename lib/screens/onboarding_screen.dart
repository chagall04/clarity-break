// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // To save completion status
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // Page indicator dots
import 'main_screen.dart'; // The main app screen to navigate to after onboarding

// Onboarding screen shown on first app launch
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(); // Controller for PageView
  bool _isLastPage = false; // Flag to track if on the last page

  // Key for SharedPreferences to track onboarding completion
  static const String _onboardingCompleteKey = 'onboardingComplete';

  // Mark onboarding as complete and navigate to the main app
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, true); // Set flag in storage

    if (mounted) { // Check if widget is still in the tree
      // Navigate to MainScreen, replacing the onboarding screen in the stack
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack( // Use Stack to overlay indicator and buttons
        children: [
          // --- PageView for swipeable content ---
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              // Update state when page changes to show/hide "Get Started" button
              setState(() {
                _isLastPage = (index == 2); // Check if it's the last page (0-indexed)
              });
            },
            children: [
              // --- Page 1: Welcome & Reset ---
              _buildPage(
                context: context,
                color: theme.colorScheme.primaryContainer.withOpacity(0.6), // Light teal background tint
                icon: Icons.refresh_rounded,
                title: "Reset Your Tolerance",
                description: "Regain sensitivity and rediscover your ideal experience with mindful breaks.",
              ),
              // --- Page 2: Understand & Track ---
              _buildPage(
                context: context,
                color: theme.colorScheme.secondaryContainer.withOpacity(0.6), // Light green background tint
                icon: Icons.edit_note_outlined, // Or Icons.timeline, Icons.insights
                title: "Track Your Journey",
                description: "Use the Journal for daily check-ins during breaks and track your experiences afterwards to gain insights.",
              ),
              // --- Page 3: Learn & Grow ---
              _buildPage(
                context: context,
                color: theme.colorScheme.tertiaryContainer.withOpacity(0.6), // Light peach background tint
                icon: Icons.library_books_outlined,
                title: "Learn & Grow",
                description: "Explore the Library for tips and info. Start your first Clarity Break when you're ready!",
              ),
            ],
          ),

          // --- Bottom Controls: Indicator and Buttons ---
          Positioned( // Position controls at the bottom
            bottom: 40.0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // --- Skip Button (optional, shows on all but last page) ---
                  _isLastPage
                      ? const SizedBox(width: 60) // Placeholder for alignment
                      : TextButton(
                    onPressed: _completeOnboarding, // Skip goes straight to main app
                    child: const Text('SKIP'),
                    style: TextButton.styleFrom(foregroundColor: theme.colorScheme.onBackground.withOpacity(0.6)),
                  ),

                  // --- Page Indicator ---
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: 3, // Number of pages
                    effect: ExpandingDotsEffect( // Nice visual effect for dots
                      dotHeight: 10,
                      dotWidth: 10,
                      activeDotColor: theme.colorScheme.primary, // Teal for active dot
                      dotColor: theme.colorScheme.onBackground.withOpacity(0.2), // Muted color for inactive dots
                    ),
                    onDotClicked: (index) { // Allow tapping dots to navigate
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),

                  // --- Next / Get Started Button ---
                  _isLastPage
                      ? // Show "Get Started" on the last page
                  TextButton( // Changed to TextButton for consistency with Skip
                    onPressed: _completeOnboarding,
                    child: const Text('GET STARTED'),
                    style: TextButton.styleFrom(foregroundColor: theme.colorScheme.primary), // Use primary color
                  )
                      : // Show "Next" arrow icon on other pages
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded),
                    color: theme.colorScheme.primary,
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // Helper widget to build the content for each onboarding page
  Widget _buildPage({
    required BuildContext context,
    required Color color, // Background tint for the page
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    return Container(
      color: color, // Apply subtle background color
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 100, // Large icon
            color: theme.colorScheme.primary, // Use primary theme color
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground, // Use default text color
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.8), // Slightly muted text
              height: 1.4, // Improve line spacing
            ),
          ),
        ],
      ),
    );
  }
}