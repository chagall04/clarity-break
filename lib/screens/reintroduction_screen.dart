// lib/screens/reintroduction_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../services/break_service.dart'; // Service for logging
import '../models/post_break_log.dart';  // Log model
import '../widgets/log_entry_dialog.dart'; // Import the dialog

// Screen for guiding reintroduction and logging usage
class ReintroductionScreen extends StatefulWidget {
  const ReintroductionScreen({super.key});

  @override
  State<ReintroductionScreen> createState() => _ReintroductionScreenState();
}

class _ReintroductionScreenState extends State<ReintroductionScreen> {
  final BreakService _breakService = BreakService();
  Future<List<PostBreakLog>>? _logsFuture; // Future for loading logs

  @override
  void initState() {
    super.initState();
    _loadLogs(); // Load logs initially
  }

  // Method to load or reload log data
  void _loadLogs() {
    setState(() {
      _logsFuture = _breakService.getPostBreakLogs();
    });
  }

  // Function to show the log entry dialog and save the result
  Future<void> _showLogDialog() async {
    final newLog = await showLogEntryDialog(context); // Show dialog
    if (newLog != null && mounted) { // Check if dialog returned a log & widget is still mounted
      await _breakService.addPostBreakLog(newLog); // Save the log
      _loadLogs(); // Refresh the list of logs on screen
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final DateFormat logFormatter = DateFormat('MMM d, HH:mm'); // Format for log entries

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reintroduction Plan'),
        elevation: 1.0,
        // Consider adding an action to clear logs?
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.delete_sweep_outlined),
        //     tooltip: 'Clear All Logs',
        //     onPressed: () async {
        //       // Add confirmation dialog
        //       await _breakService.clearPostBreakLogs();
        //       _loadLogs();
        //     },
        //   ),
        // ],
      ),
      body: SingleChildScrollView( // Allow scrolling
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Guidance Section ---
            Card(
              elevation: 1.0,
              color: theme.colorScheme.primaryContainer.withOpacity(0.5), // Subtle background tint
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back! Start Mindfully',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onPrimaryContainer),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Your tolerance is reset. Remember to:',
                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '• Start LOW (much less than before)',
                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                    ),
                    Text(
                      '• Go SLOW (wait ample time before more)',
                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                    ),
                    Text(
                      '• Listen to your body & effects',
                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24.0),

            // --- Logging Section ---
            ElevatedButton.icon(
              icon: const Icon(Icons.note_add_outlined),
              label: const Text('Log Usage'),
              onPressed: _showLogDialog, // Call function to show dialog
              style: ElevatedButton.styleFrom( // Slightly different style for this button?
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Recent Logs:',
              style: theme.textTheme.titleMedium,
            ),
            const Divider(),

            // --- Log List ---
            FutureBuilder<List<PostBreakLog>>(
              future: _logsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2.0)));
                } else if (snapshot.hasError) {
                  return Text('Error loading logs: ${snapshot.error}', style: TextStyle(color: theme.colorScheme.error));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: Text('No usage logged yet.')));
                } else {
                  final logs = snapshot.data!;
                  // Limit number of logs shown directly? Or allow full scroll?
                  // Let's show all for now within the SingleChildScrollView
                  return ListView.builder(
                    shrinkWrap: true, // Important inside SingleChildScrollView
                    physics: const NeverScrollableScrollPhysics(), // Disable ListView's own scrolling
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return ListTile(
                        dense: true, // Make list items more compact
                        leading: Chip( // Use chip for amount
                          label: Text(log.amount),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          labelPadding: const EdgeInsets.symmetric(horizontal: 6.0),
                          labelStyle: theme.textTheme.labelSmall,
                          backgroundColor: theme.colorScheme.surfaceVariant,
                          side: BorderSide.none,
                        ),
                        title: Text(logFormatter.format(log.date)), // Format date/time
                        subtitle: log.notes.isNotEmpty ? Text(log.notes, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
                        // Optional: Add onTap to view/edit log detail? (V2)
                      );
                    },
                  );
                }
              },
            ),
            const SizedBox(height: 32.0),

            // --- Future Break Suggestion ---
            Card(
              elevation: 0,
              color: theme.colorScheme.secondaryContainer.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                // side: BorderSide(color: theme.colorScheme.secondary.withOpacity(0.5))
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.calendar_month_outlined, color: theme.colorScheme.onSecondaryContainer),
                    const SizedBox(height: 8),
                    Text(
                      'Maintenance Tip:',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onSecondaryContainer),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'To maintain sensitivity, consider another Clarity Break in 8-12 weeks.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSecondaryContainer),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}