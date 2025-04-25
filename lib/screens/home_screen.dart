// lib/screens/home_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';

import '../providers/break_provider.dart';
import '../models/journal_entry.dart';
import '../services/journal_service.dart';
import '../widgets/progress_ring.dart';
import '../widgets/motivation_card.dart';
import 'break_setup_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConfettiController _confettiController;
  int _lastKnownDay = 0;
  late String _phrase;
  final List<String> _phrases = [
    "Make every sip of water count—hydrate your way to clarity.",
    "A 28-day pause brings fresh flavor back to every hit.",
    "Milk, cod liver oil, or a brisk jog: small boosts, big reset.",
    "Play sports, lift weights—let your body reset, too.",
    "Abstinence today means sharper focus tomorrow.",
    "Less often, lighter doses, lasting enjoyment.",
    "Treat your break like a mini-vacation—for your mind.",
    "One month off makes every puff feel brand new.",
    "Reset your tastebuds and your tolerance together.",
    "Switch the smoke for a smoothie—refresh from inside out.",
    "A 28-day time-out unlocks richer experiences later.",
    "Pause, hydrate, move—and watch cravings fade.",
    "Every run, every glass of water, every sober night counts.",
    "Abstinence isn’t quitting—it’s upgrading your next session.",
  ];
  final JournalService _journalService = JournalService();

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(milliseconds: 1200));
    _phrase = (_phrases..shuffle()).first; // pick a random phrase once

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bp = context.read<BreakProvider>();
      _checkAndTriggerConfetti(bp.currentBreak);
      bp.addListener(() => _checkAndTriggerConfetti(bp.currentBreak));
    });
  }

  void _checkAndTriggerConfetti(bd) {
    if (!bd.isActive) {
      _lastKnownDay = 0;
      return;
    }
    final today = bd.daysPassed;
    final milestones = [7, 14, 21, bd.totalDuration];
    if (today > _lastKnownDay && milestones.contains(today)) {
      _confettiController.play();
    }
    _lastKnownDay = today;
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bp = context.watch<BreakProvider>();
    final bd = bp.currentBreak;

    return Scaffold(
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: bd.isActive
              ? _buildActive(context, bd)
              : _buildInactive(context),
        ),
      ),
    );
  }

  Widget _buildInactive(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Image.asset('assets/images/home_inactive_graphic.png', height: 120),
        const SizedBox(height: 24),
        Text('Ready for a Refresh?',
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(
          'Start a tolerance break to refresh your experience and gain clarity.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () async {
            final res = await showBreakSetupDialog(context);
            if (res != null) {
              context
                  .read<BreakProvider>()
                  .startNewBreak(res.userWhy, res.duration);
            }
          },
          child: const Text('Start Clarity Break'),
        ),
      ]),
    );
  }

  Widget _buildActive(BuildContext context, bd) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Stack(alignment: Alignment.topCenter, children: [
        Column(children: [
          // --- Circular progress ring ---
          ProgressRing(
            progress: bd.progress,
            currentDay: bd.daysPassed,
            totalDays: bd.totalDuration,
          ),

          const SizedBox(height: 16),

          // --- Day count text ---
          Text(
            '${bd.daysPassed} ${bd.daysPassed == 1 ? "Day" : "Days"} Strong',
            style: theme.textTheme.headlineSmall,
          ),

          const SizedBox(height: 8),

          // --- Motivation message card (only once) ---
          MotivationCard(message: _phrase),

          const SizedBox(height: 24),

          // --- Hydration / self-care prompt ---
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              leading: const Icon(Icons.water_drop_outlined),
              title: const Text("Stay hydrated! 💧"),
              subtitle: const Text("Drink a glass of water right now."),
              onTap: () {
                // optionally track or log water intake...
              },
            ),
          ),

          const SizedBox(height: 24),

          // --- Weekly insights card ---
          FutureBuilder<List<JournalEntry>>(
            future: _journalService.getJournalEntries(),
            builder: (c, s) {
              if (!s.hasData) return const SizedBox();
              final weekAgo =
              DateTime.now().subtract(const Duration(days: 7));
              final recent = s.data!
                  .where((e) =>
              e.entryType == JournalEntryType.checkIn &&
                  e.date.isAfter(weekAgo))
                  .toList();
              if (recent.isEmpty) return const SizedBox();
              final moods = recent
                  .where((e) => e.moodRating != null)
                  .map((e) => e.moodRating!)
                  .toList();
              final avg = moods.isEmpty
                  ? 0
                  : (moods.reduce((a, b) => a + b) / moods.length).round();
              const emojis = ['😞', '😕', '😐', '😊', '😄'];
              final avgEmoji = (avg >= 1 && avg <= 5) ? emojis[avg - 1] : '—';
              final freq = <String, int>{};
              for (var e in recent) {
                e.changesNoticed
                    ?.forEach((c) => freq[c] = (freq[c] ?? 0) + 1);
              }
              final top = freq.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));
              final topText =
              top.isEmpty ? '—' : '${top.first.key} (${top.first.value}×)';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(children: [
                        const Text('Avg Mood'),
                        Text(avgEmoji, style: const TextStyle(fontSize: 24))
                      ]),
                      Column(children: [
                        const Text('Top Change'),
                        Text(topText)
                      ]),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // --- End / Complete Break button ---
          TextButton(
            onPressed: () => _endBreak(context, bd),
            child: Text(
              bd.daysPassed >= bd.totalDuration
                  ? 'Complete Break'
                  : 'End Break',
            ),
          ),
        ]),

        // --- Confetti overlay ---
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
          ),
        ),
      ]),
    );
  }

  Future<void> _endBreak(BuildContext context, bd) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(bd.daysPassed >= bd.totalDuration
            ? 'Complete Break?'
            : 'End Early?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes')),
        ],
      ),
    );
    if (confirm == true) {
      context.read<BreakProvider>().endCurrentBreak();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bd.daysPassed >= bd.totalDuration
              ? 'Break completed!'
              : 'Break ended early.'),
        ),
      );
    }
  }
}
