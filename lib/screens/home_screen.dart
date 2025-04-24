// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/break_provider.dart'; // Correct: uses ../ to go up one level
import '../models/break_details.dart'; // Correct: uses ../
import '../widgets/progress_ring.dart'; // Correct: uses ../
import '../widgets/motivation_card.dart'; // Correct: uses ../
import 'break_setup_dialog.dart'; // Correct path (if dialog is in screens/)

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // --- Helper Methods for Building UI Sections ---

  // Builds the UI shown when no break is active
  Widget _buildInactiveState(BuildContext context, BreakProvider provider) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Placeholder for maybe a logo or welcoming graphic later
          Icon(
            Icons.refresh, // Simple refresh icon for now
            size: 80,
            color: theme.colorScheme.secondary, // Muted green
          ),
          const SizedBox(height: 24),
          Text(
            'Ready for a Reset?',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Start a 28-day tolerance break to refresh your experience and gain clarity.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            // Style inherited from ElevatedButtonTheme in main.dart
            onPressed: () async {
              // Show the dialog to get the user's "Why"
              final String? userWhy = await showBreakSetupDialog(context);
              // If the user entered a reason and confirmed
              if (userWhy != null && userWhy.isNotEmpty) {
                // Call the provider to start the break
                // Use context.read inside callbacks/async functions
                context.read<BreakProvider>().startNewBreak(userWhy);
              }
            },
            child: const Text('Start Clarity Break'),
          ),
        ],
      ),
    );
  }

  // Builds the UI shown when a break is active
  Widget _buildActiveState(BuildContext context, BreakProvider provider) {
    final theme = Theme.of(context);
    final breakDetails = provider.currentBreak;
    const totalDays = 28; // V1 fixed duration

    // Placeholder for daily motivation - replace with real logic later
    final List<String> motivations = [
      "Day ${breakDetails.daysPassed}: You've started! The first step is often the hardest.",
      "Remember your 'Why'. Keep it close.",
      "Notice small changes: clearer thoughts? Better sleep?",
      "One day at a time. You're doing great.",
      "Cravings pass. Find a healthy distraction.",
      "Visualize the benefits of completing your break.",
      // Add more motivations for different days/stages
    ];
    // Simple logic to pick a motivation based on day (cycles through list)
    final motivationMessage = motivations[ (breakDetails.daysPassed - 1) % motivations.length ];


    return SingleChildScrollView( // Allows content to scroll if screen is small
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress Ring
          ProgressRing(
            progress: breakDetails.progress,
            currentDay: breakDetails.daysPassed,
            totalDays: totalDays,
          ),
          const SizedBox(height: 16),

          // Streak Counter (simple version)
          Text(
            '${breakDetails.daysPassed} ${breakDetails.daysPassed == 1 ? "Day" : "Days"} Strong 💪',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.secondary, // Muted green for positive reinforcement
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // "My Why" Display Card
          if (breakDetails.userWhy != null && breakDetails.userWhy!.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your "Why":',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary, // Teal title
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      breakDetails.userWhy!,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          // Add vertical space even if "My Why" is not shown
          const SizedBox(height: 8),

          // Motivation Card
          MotivationCard(message: motivationMessage),
          const SizedBox(height: 32),

          // End Break Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0), // Add padding
            child: TextButton( // Use TextButton for less emphasis than start button
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error, // Use error color for ending
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () async {
                // Show confirmation dialog before ending
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      title: const Text('End Break?'),
                      content: const Text('Are you sure you want to end your current Clarity Break?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.of(dialogContext).pop(false),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                          child: const Text('End Break'),
                          onPressed: () => Navigator.of(dialogContext).pop(true),
                        ),
                      ],
                    );
                  },
                );

                // If user confirmed, end the break
                if (confirm == true) {
                  // Use context.read inside callbacks
                  context.read<BreakProvider>().endCurrentBreak();
                  // TODO: Navigate to Reintroduction Planner or show message?
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Clarity Break ended.'),
                      duration: Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('End Current Break'),
            ),
          ),
          const SizedBox(height: 16), // Bottom padding
        ],
      ),
    );
  }


  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    // Watch the BreakProvider for changes
    final breakProvider = context.watch<BreakProvider>();

    return Scaffold(
      // AppBar is handled by MainScreen
      body: Center(
        child: AnimatedSwitcher( // Smoothly switch between states
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: breakProvider.isLoading
              ? const CircularProgressIndicator() // Show loading indicator
              : breakProvider.currentBreak.isActive
              ? _buildActiveState(context, breakProvider) // Show active UI
              : _buildInactiveState(context, breakProvider), // Show inactive UI
        ),
      ),
    );
  }
}