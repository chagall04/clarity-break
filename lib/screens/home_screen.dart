// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart'; // For Milestone Celebrations
import 'package:intl/intl.dart'; // For date calculations
import 'dart:math'; // For random confetti direction
import '../providers/break_provider.dart';
import '../models/break_details.dart';
import '../models/journal_entry.dart';
import '../services/journal_service.dart';
import '../widgets/progress_ring.dart';
import '../widgets/motivation_card.dart';
import 'break_setup_dialog.dart';
import 'package:confetti/confetti.dart';


/// Displays the main home screen: either inactive state or active break progress,
/// enriched with a weekly mood & changes summary for young adults taking clarity breaks.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConfettiController _confettiController;
  int _lastKnownDay = 0;
  final JournalService _journalService = JournalService();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 1200));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final bp = Provider.of<BreakProvider>(context, listen: false);
        _checkAndTriggerConfetti(bp.currentBreak);
        bp.addListener(_handleBreakUpdate);
      }
    });
  }

  void _handleBreakUpdate() {
    if (mounted) {
      final details = context.read<BreakProvider>().currentBreak;
      _checkAndTriggerConfetti(details);
    }
  }

  void _checkAndTriggerConfetti(BreakDetails bd) {
    if (!bd.isActive) {
      _lastKnownDay = 0;
      return;
    }
    int today = bd.daysPassed;
    int total = bd.totalDuration;
    final milestones = <int>[7, 14, 21, total];
    if (today > _lastKnownDay && milestones.contains(today)) {
      _confettiController.play();
    }
    _lastKnownDay = today;
  }

  @override
  void dispose() {
    _confettiController.dispose();
    try {
      Provider.of<BreakProvider>(context, listen: false).removeListener(_handleBreakUpdate);
    } catch (_) {}
    super.dispose();
  }

  Widget _buildInactiveState(BuildContext context, BreakProvider provider) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(
            'assets/images/home_inactive_graphic.png',
            height: 120,
            errorBuilder: (_, __, ___) {
              return Icon(Icons.spa_outlined, size: 80, color: theme.colorScheme.secondary);
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Ready for a Refresh?',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Start a tolerance break to refresh your experience and gain clarity.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.8)),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () async {
              final res = await showBreakSetupDialog(context);
              if (res != null && context.mounted) {
                context.read<BreakProvider>().startNewBreak(res.userWhy, res.duration);
              }
            },
            child: const Text('Start Clarity Break'),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveState(BuildContext context, BreakProvider provider) {
    final theme = Theme.of(context);
    final bd = provider.currentBreak;
    final total = bd.totalDuration;

    // select a motivating message based on day
    final List<String> motivations = [
      "Every sober day is a step toward clarity.",
      "Stay hydrated—sometimes thirst mimics cravings.",
      "Try a quick walk when urges hit.",
      "Remember your 'Why'—you’re making progress!",
      "Deep breaths: ride the urge wave for 15 minutes.",
      "Pick up a new hobby to stay busy.",
      "Celebrate small wins: you’ve got this!"
    ];
    final idx = (bd.daysPassed - 1).clamp(0, motivations.length - 1);
    final message = motivations.isEmpty ? "Keep focused!" : motivations[idx];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress ring & day counter
              ProgressRing(progress: bd.progress, currentDay: bd.daysPassed, totalDays: total),
              const SizedBox(height: 16),
              Text(
                '${bd.daysPassed} ${bd.daysPassed == 1 ? "Day" : "Days"} Strong 💪',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              // Optional "My Why" card
              if (bd.userWhy != null && bd.userWhy!.isNotEmpty)
                Card(
                  elevation: 1,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('“${bd.userWhy!}”', style: theme.textTheme.bodyLarge),
                  ),
                )
              else
                const SizedBox(height: 8),
              const SizedBox(height: 16),
              // Motivation card
              MotivationCard(message: message),
              const SizedBox(height: 32),

              // --- New Feature: Weekly Summary Card ---
              FutureBuilder<List<JournalEntry>>(
                future: _journalService.getJournalEntries(),
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done || !snap.hasData) {
                    return const SizedBox.shrink();
                  }
                  final all = snap.data!;
                  final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
                  final recentCheckIns = all.where((e) =>
                  e.entryType == JournalEntryType.checkIn && e.date.isAfter(oneWeekAgo)).toList();
                  if (recentCheckIns.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  // Average mood
                  final moods = recentCheckIns.where((e) => e.moodRating != null).map((e) => e.moodRating!).toList();
                  final avgMood = moods.isEmpty
                      ? 0.0
                      : moods.reduce((a, b) => a + b) / moods.length;
                  String avgEmoji;
                  if (avgMood >= 4) avgEmoji = '😄';
                  else if (avgMood >= 3) avgEmoji = '😊';
                  else if (avgMood >= 2) avgEmoji = '😕';
                  else avgEmoji = '😞';
                  // Top change
                  final freq = <String, int>{};
                  for (var e in recentCheckIns) {
                    if (e.changesNoticed != null) {
                      for (var c in e.changesNoticed!) {
                        freq[c] = (freq[c] ?? 0) + 1;
                      }
                    }
                  }
                  final sorted = freq.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
                  final topChange = sorted.isNotEmpty ? sorted.first.key : '(none)';
                  final topCount = sorted.isNotEmpty ? sorted.first.value : 0;

                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Weekly Insights', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Row(children: [
                          Text('Avg Mood:', style: theme.textTheme.bodyMedium),
                          const SizedBox(width: 8),
                          Text(avgEmoji, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 24),
                          Text('Top Change:', style: theme.textTheme.bodyMedium),
                          const SizedBox(width: 8),
                          Text('$topChange (${topCount}×)', style: theme.textTheme.bodyMedium),
                        ]),
                      ]),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // End break button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: bd.daysPassed >= total ? theme.colorScheme.primary : theme.colorScheme.error,
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) {
                        final done = bd.daysPassed >= total;
                        return AlertDialog(
                          title: Text(done ? 'Complete Break?' : 'End Break Early?'),
                          content: Text(done
                              ? 'You’ve hit your target! Mark your break as complete?'
                              : 'You haven’t reached your intended duration yet. End early?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
                          ],
                        );
                      },
                    );
                    if (confirm == true && context.mounted) {
                      HapticFeedback.mediumImpact();
                      context.read<BreakProvider>().endCurrentBreak();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(bd.daysPassed >= total ? 'Clarity Break Completed!' : 'Clarity Break Ended Early.'),
                      ));
                    }
                  },
                  child: Text(bd.daysPassed >= total ? 'Complete Break' : 'End Break'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 25,
              gravity: 0.05,
              emissionFrequency: 0.03,
              maxBlastForce: 10,
              minBlastForce: 3,
              createParticlePath: (size) => Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: 3)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BreakProvider>();
    return Scaffold(
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: provider.isLoading
              ? const CircularProgressIndicator(key: ValueKey('loading'))
              : provider.currentBreak.isActive
              ? _buildActiveState(context, provider)
              : _buildInactiveState(context, provider),
        ),
      ),
    );
  }
}
