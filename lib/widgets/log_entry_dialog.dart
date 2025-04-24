// lib/widgets/log_entry_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../models/post_break_log.dart'; // Log model

// Shows a dialog for logging post-break usage
Future<PostBreakLog?> showLogEntryDialog(BuildContext context) async {
  final theme = Theme.of(context);
  final notesController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String selectedAmount = 'Low'; // Default amount

  // Use a StatefulWidget inside the dialog builder for state management
  return showDialog<PostBreakLog>(
    context: context,
    barrierDismissible: false, // User must tap button
    builder: (BuildContext dialogContext) {
      // Use StatefulBuilder to manage state within the dialog
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Log Post-Break Use', style: theme.textTheme.headlineSmall),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  // Date Selection (Optional - Keep simple for V1?)
                  // For V1, let's just log with today's date automatically.
                  // If date selection needed: Use InkWell + Text to show date
                  // and showDatePicker on tap.

                  Text(
                      'Date: ${DateFormat('MMM d, yyyy').format(selectedDate)}', // Display today's date
                      style: theme.textTheme.bodyMedium
                  ),
                  const SizedBox(height: 16),

                  // Amount Selection (Chips)
                  Text('Amount Used:', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap( // Arrange chips nicely
                    spacing: 8.0, // Horizontal space between chips
                    children: <Widget>[
                      ChoiceChip(
                        label: const Text('Low'),
                        selected: selectedAmount == 'Low',
                        onSelected: (bool selected) {
                          setState(() { // Update state within the dialog
                            if (selected) selectedAmount = 'Low';
                          });
                        },
                        selectedColor: theme.colorScheme.secondaryContainer, // Use theme colors
                      ),
                      ChoiceChip(
                        label: const Text('Medium'),
                        selected: selectedAmount == 'Medium',
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) selectedAmount = 'Medium';
                          });
                        },
                        selectedColor: theme.colorScheme.secondaryContainer,
                      ),
                      ChoiceChip(
                        label: const Text('High'),
                        selected: selectedAmount == 'High',
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) selectedAmount = 'High';
                          });
                        },
                        selectedColor: theme.colorScheme.secondaryContainer,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Optional Notes
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'e.g., Effects, strain, feelings...',
                      // Uses InputDecorTheme from main.dart
                    ),
                    textInputAction: TextInputAction.done,
                    maxLines: 2,
                    onSubmitted: (_) { // Allow submitting via keyboard 'done'
                      // Create and return the log
                      final log = PostBreakLog(
                        date: selectedDate,
                        amount: selectedAmount,
                        notes: notesController.text.trim(),
                      );
                      Navigator.of(dialogContext).pop(log);
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Return null
                },
              ),
              FilledButton( // Use FilledButton for primary action
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: const Text('Save Log'),
                onPressed: () {
                  // Create and return the log object
                  final log = PostBreakLog(
                    date: selectedDate, // Use the selected date (which is now for V1)
                    amount: selectedAmount,
                    notes: notesController.text.trim(),
                  );
                  Navigator.of(dialogContext).pop(log); // Return the created log
                },
              ),
            ],
          );
        },
      );
    },
  );
}