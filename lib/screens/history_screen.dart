// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/break_service.dart';
import '../models/past_break.dart';
import 'break_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  final BreakService _breakService = BreakService();
  Future<List<PastBreak>>? _historyFuture;
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(vsync: this);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    _staggerController.reset();
    if (mounted) {
      _historyFuture = _breakService.getBreakHistory().then((list) {
        if (mounted) {
          final totalMs = (list.length * 100) + 300;
          _staggerController.duration = Duration(milliseconds: totalMs);
          _staggerController.forward();
        }
        return list;
      });
      setState(() {});
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = DateFormat('MMM d, yyyy');

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: FutureBuilder<List<PastBreak>>(
          future: _historyFuture,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting && snap.data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Could not load break history.\nPull down to refresh.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
                  ),
                ),
              );
            }
            final history = snap.data;
            if (history == null || history.isEmpty) {
              return _buildEmptyState(
                context,
                imageAsset: 'assets/images/empty_history.png',
                title: 'No Past Breaks Yet',
                message: 'Completed tolerance breaks will appear here.',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
              itemCount: history.length,
              itemBuilder: (context, idx) {
                final pb = history[idx];
                final start = idx * 0.1;
                final end = start + 0.5;
                final animation = CurvedAnimation(
                  parent: _staggerController,
                  curve: Interval(start, end, curve: Curves.easeOut),
                );

                return SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
                      .animate(animation),
                  child: FadeTransition(
                    opacity: animation,
                    child: _buildHistoryCard(pb, formatter, theme),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHistoryCard(PastBreak pb, DateFormat fmt, ThemeData theme) {
    final completed = pb.completedFullDuration;
    final range = '${fmt.format(pb.startDate)} - ${fmt.format(pb.endDate)}';
    final durationLabel = '${pb.durationAchieved} / ${pb.intendedDuration} Days';

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BreakDetailScreen(pastBreak: pb)),
        );
      },
      child: Card(
        elevation: 1.5,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(range,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                  ),
                  Chip(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                    label: Text(durationLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: completed
                                ? theme.colorScheme.onSecondaryContainer
                                : theme.colorScheme.onErrorContainer)),
                    backgroundColor: completed
                        ? theme.colorScheme.secondaryContainer
                        : theme.colorScheme.errorContainer.withOpacity(0.7),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (pb.userWhy.isNotEmpty)
                Text('Reason: ${pb.userWhy}', style: theme.textTheme.bodyLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
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
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imageAsset,
              height: 150,
              semanticLabel: title,
              errorBuilder: (_, __, ___) {
                debugPrint("Failed to load empty state image: $imageAsset");
                return Icon(Icons.history_outlined,
                    size: 100, color: theme.colorScheme.primary.withOpacity(0.5));
              },
            ),
            const SizedBox(height: 24),
            Text(title,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
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
}
