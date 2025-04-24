// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';     // For date formatting
import '../services/break_service.dart'; // Service to load break history
import '../models/past_break.dart';     // Model for past break data
// Removed import for reintroduction_screen.dart

// Screen that displays a list of past tolerance breaks
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final BreakService _breakService = BreakService(); // Service instance
  Future<List<PastBreak>>? _historyFuture; // Future holding the history data

  @override
  void initState() {
    super.initState();
    _loadHistory(); // Load history when the screen is first displayed
  }

  // Method to trigger loading or reloading of history data
  void _loadHistory() {
    setState(() {
      _historyFuture = _breakService.getBreakHistory(); // Fetch data from service
    });
  }

  // Removed _navigateToReintroduction function

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access theme for styling
    // Define date format for display
    final DateFormat formatter = DateFormat('MMM d, yyyy');

    return Scaffold(
      // AppBar is handled by MainScreen
      body: RefreshIndicator( // Enable pull-to-refresh functionality
        onRefresh: () async => _loadHistory(), // Reload data on refresh
        child: FutureBuilder<List<PastBreak>>(
          future: _historyFuture, // Data source for the builder
          builder: (context, snapshot) {
            // --- Handle different data loading states ---
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              // Show loading indicator only on initial load
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Display error message if loading failed
              print('HistoryScreen Error: ${snapshot.error}'); // Log error for debugging
              return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Could not load break history.\nPull down to refresh.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
                    ),
                  )
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // Display message if no history exists
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'No past breaks recorded yet.\nComplete a break to see it here!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.7)),
                  ),
                ),
              );
            } else {
              // --- Data loaded successfully, build the history list ---
              final history = snapshot.data!; // Get the list of past breaks
              return ListView.builder(
                padding: const EdgeInsets.all(8.0), // Padding around the list view
                itemCount: history.length, // Number of items in the list
                itemBuilder: (context, index) {
                  final pastBreak = history[index]; // Get data for current item
                  final daysText = pastBreak.durationAchieved == 1 ? 'Day' : 'Days'; // Pluralize 'Day'

                  // Build a Card widget for each past break entry
                  return Card(
                    elevation: 1.5, // Use theme's card elevation or customize
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Padding inside card
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row for date range and duration chip
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Display formatted date range
                              Text(
                                '${formatter.format(pastBreak.startDate)} - ${formatter.format(pastBreak.endDate)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7), // Slightly muted color
                                ),
                              ),
                              // Display duration chip, colored by completion status
                              Chip(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                                label: Text(
                                  '${pastBreak.durationAchieved} $daysText',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    // Use contrasting text colors for chip backgrounds
                                      color: pastBreak.completedFullDuration
                                          ? theme.colorScheme.onSecondaryContainer
                                          : theme.colorScheme.onErrorContainer
                                  ),
                                ),
                                // Use theme colors for chip background based on completion
                                backgroundColor: pastBreak.completedFullDuration
                                    ? theme.colorScheme.secondaryContainer
                                    : theme.colorScheme.errorContainer.withOpacity(0.7),
                                side: BorderSide.none, // No border on chip
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0), // Spacing
                          // Display user's reason ("Why") if available
                          if (pastBreak.userWhy.isNotEmpty)
                            Text(
                              'Reason: ${pastBreak.userWhy}',
                              style: theme.textTheme.bodyLarge,
                              maxLines: 2, // Limit lines to prevent overflow
                              overflow: TextOverflow.ellipsis, // Add '...' if text exceeds lines
                            ),
                          // Removed the conditional button for reintroduction planning
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}