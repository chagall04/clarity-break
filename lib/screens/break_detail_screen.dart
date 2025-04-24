import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/past_break.dart';
import '../models/journal_entry.dart';
import '../services/journal_service.dart';
import '../widgets/journal_entry_card.dart';

class BreakDetailScreen extends StatefulWidget {
  final PastBreak pastBreak;
  const BreakDetailScreen({super.key, required this.pastBreak});

  @override
  State<BreakDetailScreen> createState() => _BreakDetailScreenState();
}

class _BreakDetailScreenState extends State<BreakDetailScreen> {
  final JournalService _journalService = JournalService();
  Future<List<JournalEntry>>? _checkInsFuture;

  @override
  void initState() {
    super.initState();
    _loadCheckIns();
  }

  void _loadCheckIns() {
    setState(() {
      _checkInsFuture =
          _journalService.getJournalEntries().then((all) => all.where((e) {
            return e.entryType == JournalEntryType.checkIn &&
                !e.date.isBefore(widget.pastBreak.startDate) &&
                !e.date.isAfter(widget.pastBreak.endDate);
          }).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFmt = DateFormat('MMM d, yyyy');
    final dtFmt = DateFormat('MMM d, yyyy HH:mm');
    final completed = widget.pastBreak.durationAchieved >=
        widget.pastBreak.intendedDuration;

    return Scaffold(
      appBar: AppBar(
        title: Text('Break Details (${dateFmt.format(widget.pastBreak.startDate)})'),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Summary Card
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Duration:',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        Chip(
                          label: Text(
                              '${widget.pastBreak.durationAchieved} / ${widget.pastBreak.intendedDuration} Days'),
                          backgroundColor: completed
                              ? theme.colorScheme.secondaryContainer
                              : theme.colorScheme.errorContainer
                              .withOpacity(0.7),
                          labelStyle: theme.textTheme.labelMedium?.copyWith(
                              color: completed
                                  ? theme.colorScheme.onSecondaryContainer
                                  : theme.colorScheme.onErrorContainer),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Dates:',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                    Text(
                      '${dtFmt.format(widget.pastBreak.startDate)} - ${dtFmt.format(widget.pastBreak.endDate)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text('Your "Why":',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                    Text(
                      widget.pastBreak.userWhy.isNotEmpty
                          ? widget.pastBreak.userWhy
                          : '(Not specified)',
                      style: theme.textTheme.bodyLarge?.copyWith(
                          fontStyle: widget.pastBreak.userWhy.isEmpty
                              ? FontStyle.italic
                              : FontStyle.normal),
                    ),
                  ]),
            ),
          ),

          const SizedBox(height: 24),

          // Mood Chart
          Text('Mood Over Time', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          FutureBuilder<List<JournalEntry>>(
            future: _checkInsFuture,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const SizedBox(
                    height: 200, child: Center(child: CircularProgressIndicator()));
              }
              final entries = snap.data!;
              if (entries.isEmpty) {
                return SizedBox(
                  height: 200,
                  child: Center(
                    child: Text('No mood check-ins this period.',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ),
                );
              }
              return SizedBox(
                  height: 200,
                  child: _MoodLineChart(
                    entries: entries,
                    totalDays: widget.pastBreak.durationAchieved,
                  ));
            },
          ),

          const SizedBox(height: 24),

          // Usage Bar Chart (unstyled example)
          Text('Usage Frequency', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          const SizedBox(height: 200, child: _UsageBarChart()),

          const SizedBox(height: 24),

          // Daily Check-ins List
          Text('Daily Check-ins During This Break:',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
          const Divider(height: 16),
          FutureBuilder<List<JournalEntry>>(
            future: _checkInsFuture,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final entries = snap.data!;
              if (entries.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text('No daily check-ins were logged.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                  ),
                );
              }
              entries.sort((a, b) => a.date.compareTo(b.date));
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entries.length,
                itemBuilder: (_, idx) => JournalEntryCard(entry: entries[idx]),
              );
            },
          ),

          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

/// Interactive Mood line chart
class _MoodLineChart extends StatelessWidget {
  final List<JournalEntry> entries;
  final int totalDays;
  const _MoodLineChart({required this.entries, required this.totalDays});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // map check-ins to FlSpots
    final spots = entries.asMap().entries.map((e) {
      final day = e.key + 1;
      final mood = e.value.moodRating?.toDouble() ?? 1.0;
      return FlSpot(day.toDouble(), mood);
    }).toList();

    return LineChart(
      LineChartData(
        minX: 1,
        maxX: totalDays.toDouble(),
        minY: 1,
        maxY: 5,
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (v, _) => Text('D${v.toInt()}',
                  style: theme.textTheme.bodySmall),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (v, _) {
                const emojis = ['😞', '😕', '😐', '😊', '😄'];
                int idx = v.toInt().clamp(1, 5) - 1;
                return Text(emojis[idx]);
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.primary.withOpacity(0.2)),
            color: theme.colorScheme.primary,
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: theme.colorScheme.surfaceVariant,
            getTooltipItems: (touched) => touched.map((t) {
              return LineTooltipItem(
                'Day ${t.x.toInt()}\nMood: ${t.y.toInt()}',
                theme.textTheme.bodySmall!,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// Unchanged usage bar chart
class _UsageBarChart extends StatelessWidget {
  const _UsageBarChart({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Usage chart placeholder'));
}
