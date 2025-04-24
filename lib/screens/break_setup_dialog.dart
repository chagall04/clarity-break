// lib/screens/break_setup_dialog.dart
import 'package:flutter/material.dart';

// Shows a dialog to get the user's reason for starting a break
Future<String?> showBreakSetupDialog(BuildContext context) async {
  final theme = Theme.of(context);
  final whyController = TextEditingController(); // Controller for the text field

  return showDialog<String>(
    context: context,
    barrierDismissible: false, // User must tap button to close
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(
          'Start Your Clarity Break',
          style: theme.textTheme.headlineSmall,
        ),
        content: SingleChildScrollView( // In case content overflows
          child: ListBody(
            children: <Widget>[
              Text(
                'Take a moment to write down why you want to take this 28-day break. Seeing your reason can help you stay motivated!',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: whyController,
                autofocus: true, // Automatically focus the text field
                decoration: const InputDecoration(
                  labelText: 'My Reason ("My Why")',
                  hintText: 'e.g., To reset my tolerance, improve focus...',
                  // Uses InputDecorTheme from main.dart
                ),
                textInputAction: TextInputAction.done, // Show 'done' on keyboard
                maxLines: 3, // Allow a few lines for the reason
                onSubmitted: (_) { // Allow submitting via keyboard 'done'
                  final whyText = whyController.text.trim();
                  if (whyText.isNotEmpty) {
                    Navigator.of(dialogContext).pop(whyText);
                  }
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Return null on cancel
            },
          ),
          // Use the primary color for the confirmation button
          FilledButton( // Using FilledButton for emphasis
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary, // Teal
              foregroundColor: theme.colorScheme.onPrimary, // White text
            ),
            child: const Text('Begin 28-Day Break'),
            onPressed: () {
              final whyText = whyController.text.trim(); // Get text and remove whitespace
              // Only pop with text if something was entered
              if (whyText.isNotEmpty) {
                Navigator.of(dialogContext).pop(whyText);
              } else {
                // Optional: Show a small validation message or shake animation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter your reason first!'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
      );
    },
  );
}