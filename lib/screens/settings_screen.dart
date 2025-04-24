// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/break_provider.dart'; // Provider for reminder settings & state reload
import '../services/journal_service.dart'; // Service for clearing journal data
import '../services/break_service.dart'; // Service for clearing break history

// Screen for managing application settings like reminders and data
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Helper function to show the time picker dialog and update provider state
  Future<void> _selectTime(BuildContext context, BreakProvider provider) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: provider.reminderTime, // Show current time initially
      helpText: 'Select Reminder Time', // Customize dialog text
      builder: (context, child) { // Optional: Apply theme to time picker
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith( // Example: match primary color
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    // If a time was picked and it's different from the current time
    if (picked != null &&
        (picked.hour != provider.reminderTime.hour || picked.minute != provider.reminderTime.minute) ) {
      // Use context.read for calling methods inside async functions or callbacks
      context.read<BreakProvider>().setReminderTime(picked);
    }
  }

  // Helper function to show data reset confirmation dialog and execute reset
  Future<void> _confirmAndResetData(BuildContext context) async {
    final theme = Theme.of(context); // Get theme for dialog styling
    // Show confirmation dialog before deleting data
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must explicitly choose an action
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Data Reset'),
        content: const Text('Are you absolutely sure you want to delete all break history and journal entries? This cannot be undone.'),
        actions: [
          TextButton( // Cancel button
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(ctx).pop(false) // Return false on cancel
          ),
          TextButton( // Reset button (use error color for emphasis)
              style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
              child: const Text('RESET ALL DATA'),
              onPressed: () => Navigator.of(ctx).pop(true) // Return true to confirm reset
          ),
        ],
      ),
    );

    // If user confirmed reset and widget is still mounted
    if (confirm == true && context.mounted) {
      // Call service methods to clear persistent data
      await JournalService().clearAllJournalEntries(); // Clear Journal entries
      await BreakService().clearHistory(); // *** Clear Break history ***

      // Reload provider state to reflect cleared data in the UI
      // Use read because we're inside an async callback after await
      await context.read<BreakProvider>().reloadAllState();
      // TODO: Reload Journal screen state if needed (e.g., using its own provider/notifier)

      // Show confirmation snackbar to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('All app data has been reset.'),
            behavior: SnackBarBehavior.floating // Floating style looks modern
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Watch provider to rebuild UI when reminder settings change
    final breakProvider = context.watch<BreakProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        // Theme elevation applied automatically
      ),
      body: ListView( // Use ListView for scrollable settings items
        padding: const EdgeInsets.symmetric(vertical: 8.0), // Add vertical padding
        children: <Widget>[
          // --- Reminder Settings Section ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text( // Section header text
              'Daily Reminder',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
            ),
          ),
          SwitchListTile( // Toggle switch for enabling/disabling reminders
            title: const Text('Enable Daily Check-in'),
            subtitle: const Text('Get reminders during your break.'),
            value: breakProvider.remindersEnabled, // Get current value from provider
            onChanged: (bool value) {
              // Call provider method to update setting (use context.read in callbacks)
              context.read<BreakProvider>().setRemindersEnabled(value);
            },
            secondary: Icon( // Icon indicating reminder status
              breakProvider.remindersEnabled ? Icons.notifications_active_outlined : Icons.notifications_off_outlined,
              color: Theme.of(context).colorScheme.secondary, // Use secondary color for icon
            ),
            activeColor: theme.colorScheme.primary, // Color of the active switch toggle
          ),
          ListTile( // Tappable item to set reminder time
            title: const Text('Reminder Time'),
            subtitle: Text(breakProvider.reminderTime.format(context)), // Display formatted time
            trailing: Icon(Icons.edit_outlined, color: theme.colorScheme.primary.withOpacity(breakProvider.remindersEnabled ? 1.0 : 0.4)), // Dim edit icon if disabled
            onTap: breakProvider.remindersEnabled // Only allow tap if reminders are enabled
                ? () => _selectTime(context, breakProvider) // Show time picker on tap
                : null, // Disable tap otherwise
            enabled: breakProvider.remindersEnabled, // Visually enable/disable tile based on reminder status
          ),
          const Divider(height: 24.0, indent: 16, endIndent: 16), // Visual separator

          // --- Data Management Section ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text( // Section header text
              'Data Management',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
            ),
          ),
          ListTile( // Tappable item to reset all data
            leading: Icon(Icons.delete_sweep_outlined, color: theme.colorScheme.error), // Warning icon
            title: Text('Reset All App Data', style: TextStyle(color: theme.colorScheme.error)), // Use error color for text
            subtitle: const Text('Deletes break history & journal entries.'),
            onTap: () => _confirmAndResetData(context), // Call confirmation helper on tap
          ),
          const Divider(height: 24.0, indent: 16, endIndent: 16), // Visual separator

          // --- About Section ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text( // Section header text
              'About',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
            ),
          ),
          ListTile( // Tappable item to show About dialog
            leading: const Icon(Icons.info_outline),
            title: const Text('About Clarity Break'),
            subtitle: const Text('Version 1.0.0'), // TODO: Get version dynamically using package_info_plus
            onTap: () {
              // Show standard Flutter About dialog
              showAboutDialog(
                  context: context,
                  applicationName: 'Clarity Break',
                  applicationVersion: '1.0.0', // Replace with dynamic version later
                  applicationLegalese: '© 2024 YourName', // Replace with your legal info
                  applicationIcon: const Padding( // Add padding around icon
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.spa_outlined, size: 32) // Use app icon or relevant placeholder
                  ),
                  children: [ // Add custom text to the dialog
                    const Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Text('Manage your tolerance breaks mindfully. All data stays on your device and is never shared.', textAlign: TextAlign.center,)
                    )
                    // TODO: Add link to a formal Privacy Policy here later
                  ]
              );
            },
          ),
        ],
      ),
    );
  }
}