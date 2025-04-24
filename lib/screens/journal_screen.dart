// lib/screens/journal_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/break_provider.dart';
import '../services/journal_service.dart';
import '../models/journal_entry.dart';
import '../widgets/journal_entry_dialog.dart';
import '../widgets/journal_entry_card.dart';
import '../widgets/gradient_button.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen>
    with TickerProviderStateMixin {  // <-- changed here
  final JournalService _journalService = JournalService();
  Future<List<JournalEntry>>? _entriesFuture;
  late AnimationController _fadeController;
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _staggerController = AnimationController(vsync: this);
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    _fadeController.reset();
    _staggerController.reset();
    if (mounted) {
      _entriesFuture = _journalService.getJournalEntries().then((entries) {
        if (mounted) {
          _fadeController.forward();
          final totalMs = (entries.length * 100) + 300;
          _staggerController.duration = Duration(milliseconds: totalMs);
          _staggerController.forward();
        }
        return entries;
      });
      setState(() {});
    }
  }

  Future<void> _showEntryDialog(bool isOnBreak) async {
    final entry = await showJournalEntryDialog(
      context,
      isOnBreak: isOnBreak,
    );
    if (entry != null && mounted) {
      await _journalService.addJournalEntry(entry);
      _loadEntries();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  Widget _buildEmptyState(
      BuildContext context, {
        required String imageAsset,
        required String title,
        required String message,
      }) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Image.asset(imageAsset, height: 120, fit: BoxFit.contain),
            const SizedBox(height: 24),
            Text(title,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(message,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.7)),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakProv = context.watch<BreakProvider>();
    final isOnBreak = breakProv.currentBreak.isActive;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadEntries,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: GradientButton(
                onPressed: () => _showEntryDialog(isOnBreak),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isOnBreak
                          ? Icons.checklist_rtl_outlined
                          : Icons.add_chart_outlined,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isOnBreak ? 'Daily Check-in' : 'Track Experience',
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Recent Entries',
                    style: theme.textTheme.titleMedium),
              ),
            ),
            const Divider(indent: 16, endIndent: 16),
            Expanded(
              child: FutureBuilder<List<JournalEntry>>(
                future: _entriesFuture,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting &&
                      !_fadeController.isAnimating) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Text(
                        'Error loading journal entries: ${snap.error}',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    );
                  }
                  final entries = snap.data;
                  if (entries == null || entries.isEmpty) {
                    return _buildEmptyState(
                      context,
                      imageAsset: 'assets/images/empty_journal.png',
                      title: 'Your Journal is Empty',
                      message:
                      'Tap the button above to add your first check-in or track an experience!',
                    );
                  }
                  return FadeTransition(
                    opacity: _fadeController,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 80),
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final item = entries[index];
                        final start = (index * 0.1).clamp(0.0, 1.0);
                        final end = ((index * 0.1) + 0.4).clamp(0.0, 1.0);
                        final animation = CurvedAnimation(
                          parent: _staggerController,
                          curve: Interval(start, end, curve: Curves.easeOut),
                        );
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.1),
                              end: Offset.zero,
                            ).animate(animation),
                            child: JournalEntryCard(entry: item),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
