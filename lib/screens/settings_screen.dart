// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/break_provider.dart'; // Provider for reminder settings
import '../services/journal_service.dart'; // Service for clearing journal data
// TODO: Import BreakService if reset needs to clear history too

// Screen for managing app settings
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Helper function to show the time picker dialog
  Future<void> _selectTime(BuildContext context, BreakProvider provider) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: provider.reminderTime, // Show current time initially
    );
    // If a time was picked and it's different from the current time
    if (picked != null &&
        (picked.hour != provider.reminderTime.hour || picked.minute != provider.reminderTime.minute) ) {
      // Use context.read for calling methods inside async functions or callbacks
      context.read<BreakProvider>().setReminderTime(picked);
    }
  }

  // Helper function to show data reset confirmation
  Future<void> _confirmAndResetData(BuildContext context) async {
    final theme = Theme.of(context); // Get theme for dialog styling
    // Show confirmation dialog before deleting data
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must explicitly choose
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Data Reset'),
        content: const Text('Are you absolutely sure you want to delete all break history and journal entries? This cannot be undone.'),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(ctx).pop(false)),
          TextButton(
              style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error), // Use error color for reset button
              child: const Text('RESET ALL DATA'),
              onPressed: () => Navigator.of(ctx).pop(true) // Confirm reset
          ),
        ],
      ),
    );

    // If user confirmed and widget is still mounted
    if (confirm == true && context.mounted) {
      // Call service methods to clear data
      await JournalService().clearAllJournalEntries();
      // TODO: Add call to clear break history from BreakService if needed
      // await context.read<BreakService>().clearHistory();

      // Reload provider state to reflect cleared data
      // Use read because we're inside an async callback after await
      await context.read<BreakProvider>().reloadAllState();

      // Show confirmation snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All app data has been reset.'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Watch provider to rebuild UI when settings change
    final breakProvider = context.watch<BreakProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 1.0, // Use theme's default elevation
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0), // Add vertical padding
        children: <Widget>[
          // --- Reminder Settings Section ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text( // Section header
              'Daily Reminder',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
            ),
          ),
          SwitchListTile(
            title: const Text('Enable Daily Check-in'),
            subtitle: const Text('Get reminders during your break.'),
            value: breakProvider.remindersEnabled, // Get current value from provider
            onChanged: (bool value) {
              // Call provider method to update setting (use read)
              context.read<BreakProvider>().setRemindersEnabled(value);
            },
            secondary: Icon( // Add an icon
              breakProvider.remindersEnabled ? Icons.notifications_active_outlined : Icons.notifications_off_outlined,
              color: Theme.of(context).colorScheme.secondary,
            ),
            activeColor: theme.colorScheme.primary, // Color of the switch toggle
          ),
          ListTile(
            title: const Text('Reminder Time'),
            subtitle: Text(breakProvider.reminderTime.format(context)), // Display formatted time
            trailing: Icon(Icons.edit_outlined, color: theme.colorScheme.primary.withOpacity(breakProvider.remindersEnabled ? 1.0 : 0.5)), // Dim icon if disabled
            onTap: breakProvider.remindersEnabled // Only allow tap if reminders are enabled
                ? () => _selectTime(context, breakProvider) // Show time picker
                : null, // Disable tap otherwise
            enabled: breakProvider.remindersEnabled, // Visually enable/disable tile
          ),
          const Divider(height: 24.0, indent: 16, endIndent: 16),

          // --- Data Management Section ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text( // Section header
              'Data Management',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
            ),
          ),
          ListTile(
            leading: Icon(Icons.delete_sweep_outlined, color: theme.colorScheme.error), // Use a more indicative icon
            title: Text('Reset All App Data', style: TextStyle(color: theme.colorScheme.error)),
            subtitle: const Text('Deletes break history & journal entries.'),
            onTap: () => _confirmAndResetData(context), // Call confirmation helper
          ),
          const Divider(height: 24.0, indent: 16, endIndent: 16),

          // --- About Section ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text( // Section header
              'About',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Clarity Break'),
            subtitle: const Text('Version 1.0.0'), // TODO: Get version dynamically later
            onTap: () {
              // Show standard About dialog
              showAboutDialog(
                  context: context,
                  applicationName: 'Clarity Break',
                  applicationVersion: '1.0.0', // Replace with dynamic version later using package_info_plus
                  applicationLegalese: '© 2024 YourName', // Replace with your legalese
                  applicationIcon: const Icon(Icons.spa_outlined, size: 40), // Use placeholder icon or logo
                  children: [
                    const Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Text('Manage your tolerance breaks mindfully. All data stays on your device.') // Brief description
                    )
                    // TODO: Add Privacy Policy link/text here later
                  ]
              );
            },
          ),
        ],
      ),
    );
  }
}