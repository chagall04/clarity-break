// lib/screens/journal_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Date formatting
import '../providers/break_provider.dart'; // To check break status
import '../services/journal_service.dart'; // To load/save entries
import '../models/journal_entry.dart'; // Entry model
import '../widgets/journal_entry_dialog.dart'; // Dialog for adding entries
import '../widgets/journal_entry_card.dart'; // Widget to display each entry

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final JournalService _journalService = JournalService();
  Future<List<JournalEntry>>? _entriesFuture;

  @override
  void initState() {
    super.initState();
    _loadEntries(); // Load entries when screen initializes
  }

  // Method to load or reload journal entries
  void _loadEntries() {
    setState(() {
      _entriesFuture = _journalService.getJournalEntries();
    });
  }

  // Function to show the correct entry dialog
  Future<void> _showEntryDialog(bool isOnBreak) async {
    // Call the new universal dialog function (we'll create this next)
    final newEntry = await showJournalEntryDialog(context, isOnBreak: isOnBreak);
    if (newEntry != null && mounted) {
      await _journalService.addJournalEntry(newEntry);
      _loadEntries(); // Refresh list
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Watch break provider to determine which button/dialog to show
    final breakProvider = context.watch<BreakProvider>();
    final bool isOnBreak = breakProvider.currentBreak.isActive;

    return Scaffold(
      // AppBar handled by MainScreen
      body: RefreshIndicator(
        onRefresh: () async => _loadEntries(), // Pull to refresh
        child: Column( // Use Column for button + list
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: Icon(isOnBreak ? Icons.checklist_rtl_outlined : Icons.add_chart_outlined),
                label: Text(isOnBreak ? 'Daily Check-in' : 'Track Experience'),
                onPressed: () => _showEntryDialog(isOnBreak), // Show the relevant dialog
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48), // Make button wide
                ),
              ),
            ),
            // --- Guidance Card (Conditional) ---
            // TODO: Implement logic to show guidance card only after break ends
            // if (showGuidance) ...[
            //   Card(...)
            // ],

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Recent Entries', style: theme.textTheme.titleMedium),
            ),
            const Divider(indent: 16, endIndent: 16),

            // --- Entries List ---
            Expanded( // Make the list take remaining space
              child: FutureBuilder<List<JournalEntry>>(
                future: _entriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error loading entries: ${snapshot.error}', style: TextStyle(color: theme.colorScheme.error)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'No journal entries yet.\nTap the button above to add one!',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.7)),
                        ),
                      ),
                    );
                  } else {
                    final entries = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0), // Adjust padding
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        // Use a dedicated widget to display each entry type nicely
                        return JournalEntryCard(entry: entries[index]);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}