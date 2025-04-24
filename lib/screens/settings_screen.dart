// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/break_provider.dart';
import '../providers/theme_provider.dart';
import '../services/journal_service.dart';
import '../services/break_service.dart';
import '../services/data_service.dart';
import 'faq_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _selectTime(BuildContext context) async {
    final provider = context.read<BreakProvider>();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: provider.reminderTime,
      helpText: 'Select Reminder Time',
    );
    if (picked != null &&
        (picked.hour != provider.reminderTime.hour ||
            picked.minute != provider.reminderTime.minute)) {
      await provider.setReminderTime(picked);
    }
  }

  Future<void> _confirmAndResetData(BuildContext context) async {
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Data Reset'),
        content: const Text(
            'Are you sure you want to delete all break history and journal entries?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            child: const Text('RESET ALL DATA'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await JournalService().clearAllJournalEntries();
      await BreakService().clearHistory();
      await context.read<BreakProvider>().reloadAllState();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All app data has been reset.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      await DataService.exportData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data exported successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to export data.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _importData(BuildContext context) async {
    final success = await DataService.importData();
    if (success) {
      await context.read<BreakProvider>().reloadAllState();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data imported successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data import cancelled or failed.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakProvider = context.watch<BreakProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Appearance',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
            ),
          ),
          ListTile(
            title: const Text('App Theme'),
            subtitle: Text(_themeLabel(themeProvider.mode)),
            trailing: DropdownButton<ThemeMode>(
              value: themeProvider.mode,
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
              onChanged: (mode) {
                if (mode != null) themeProvider.setMode(mode);
              },
            ),
          ),
          const Divider(height: 24, indent: 16, endIndent: 16),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Daily Reminder',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
            ),
          ),
          SwitchListTile(
            title: const Text('Enable Daily Check-in'),
            subtitle: const Text('Get reminders during your break.'),
            value: breakProvider.remindersEnabled,
            onChanged: (value) {
              breakProvider.setRemindersEnabled(value);
            },
            secondary: Icon(
              breakProvider.remindersEnabled
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
              color: theme.colorScheme.secondary,
            ),
            activeColor: theme.colorScheme.primary,
          ),
          ListTile(
            title: const Text('Reminder Time'),
            subtitle: Text(breakProvider.reminderTime.format(context)),
            trailing: Icon(
              Icons.edit_outlined,
              color: theme.colorScheme.primary.withOpacity(
                  breakProvider.remindersEnabled ? 1.0 : 0.4),
            ),
            enabled: breakProvider.remindersEnabled,
            onTap:
            breakProvider.remindersEnabled ? () => _selectTime(context) : null,
          ),
          const Divider(height: 24, indent: 16, endIndent: 16),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Data Management',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Export All Data'),
            subtitle: const Text('Save a backup JSON of your entries & history.'),
            onTap: () => _exportData(context),
          ),
          ListTile(
            leading: const Icon(Icons.upload_outlined),
            title: const Text('Import Data'),
            subtitle: const Text('Restore from a previously exported JSON backup.'),
            onTap: () => _importData(context),
          ),
          ListTile(
            leading:
            Icon(Icons.delete_sweep_outlined, color: theme.colorScheme.error),
            title: Text('Reset All App Data',
                style: TextStyle(color: theme.colorScheme.error)),
            subtitle: const Text('Deletes break history & journal entries.'),
            onTap: () => _confirmAndResetData(context),
          ),
          const Divider(height: 24, indent: 16, endIndent: 16),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Help & Feedback',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('User Guide & FAQ'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FaqScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Clarity Break'),
            subtitle: const Text('Version 1.0.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Clarity Break',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 Clarity Break Inc.',
              );
            },
          ),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      default:
        return 'System';
    }
  }
}
