// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/break_service.dart';
import '../models/past_break.dart';
import 'reintroduction_screen.dart'; // <<<=== IMPORT ReintroductionScreen

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final BreakService _breakService = BreakService();
  Future<List<PastBreak>>? _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _historyFuture = _breakService.getBreakHistory();
    });
  }

  // Function to navigate to Reintroduction Screen
  void _navigateToReintroduction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReintroductionScreen()),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final DateFormat formatter = DateFormat('MMM d, yyyy');

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _loadHistory(),
        child: FutureBuilder<List<PastBreak>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            // --- Handle different states (Loading, Error, Empty) ---
            // [ Omitted for brevity - Keep existing Loading/Error/Empty checks ]
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print('HistoryScreen Error: ${snapshot.error}');
              return Center( /* Error Message */ );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center( /* Empty History Message */ );
            } else {
              // --- Data loaded successfully ---
              final history = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final pastBreak = history[index];
                  final daysText = pastBreak.durationAchieved == 1 ? 'Day' : 'Days';
                  // Check if this is the most recent break (index 0 because list is sorted newest first)
                  final bool isMostRecent = index == 0;

                  return Card(
                    elevation: 1.5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(/* Date Range and Duration Chip - Keep as is */
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${formatter.format(pastBreak.startDate)} - ${formatter.format(pastBreak.endDate)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                                ),
                              ),
                              Chip(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                                label: Text(
                                  '${pastBreak.durationAchieved} $daysText',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                      color: pastBreak.completedFullDuration
                                          ? theme.colorScheme.onSecondary // Use onSecondary for contrast
                                          : theme.colorScheme.onErrorContainer // Use onErrorContainer for contrast
                                  ),
                                ),
                                backgroundColor: pastBreak.completedFullDuration
                                    ? theme.colorScheme.secondary // Green for completed
                                    : theme.colorScheme.errorContainer.withOpacity(0.7), // Reddish tint for incomplete
                                side: BorderSide.none,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          if (pastBreak.userWhy.isNotEmpty)
                            Text(/* "My Why" Text - Keep as is */
                              'Reason: ${pastBreak.userWhy}',
                              style: theme.textTheme.bodyLarge,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                          // *** NEW: Add button/divider for most recent break ***
                          if (isMostRecent) ...[ // Use collection-if to add widgets conditionally
                            const Divider(height: 16.0, thickness: 1),
                            Align( // Align button to the right
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                icon: Icon(Icons.arrow_forward, size: 16, color: theme.colorScheme.primary),
                                label: Text('Plan Reintroduction', style: TextStyle(color: theme.colorScheme.primary)),
                                onPressed: () => _navigateToReintroduction(context),
                                style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8)
                                ),
                              ),
                            )
                          ]
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