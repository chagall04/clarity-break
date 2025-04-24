// lib/widgets/journal_entry_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';

// Displays a single journal entry based on its type
class JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;

  const JournalEntryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    switch (entry.entryType) {
      case JournalEntryType.checkIn:
        return _buildCheckInCard(context);
      case JournalEntryType.usage:
        return _buildUsageCard(context);
      case JournalEntryType.abstinence:
        return _buildAbstinenceCard(context);
    }
  }

  // --- Build Card for Check-in Entry ---
  Widget _buildCheckInCard(BuildContext context) {
    final theme = Theme.of(context);
    final DateFormat formatter = DateFormat('MMM d, yyyy');
    final emojis = ['?', '😞', '😕', '😐', '😊', '😄']; // Index 0 for null/invalid

    return Card(
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row( // Header: Date and Mood
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatter.format(entry.date), style: theme.textTheme.bodySmall),
                Text(emojis[entry.moodRating ?? 0], style: const TextStyle(fontSize: 20)),
              ],
            ),
            const Divider(height: 12),
            if (entry.cravingsPresentCheckin != null)
              Text('Cravings: ${entry.cravingsPresentCheckin! ? "Yes" : "No"}', style: theme.textTheme.bodyMedium),
            if (entry.changesNoticed != null && entry.changesNoticed!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(spacing: 6, runSpacing: 4, children: entry.changesNoticed!.map((change) => Chip(label: Text(change), padding: EdgeInsets.zero, visualDensity: VisualDensity.compact, labelStyle: theme.textTheme.labelSmall)).toList()),
            ],
            if (entry.notes.isNotEmpty)...[
              const SizedBox(height: 6),
              Text('Notes: ${entry.notes}', style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic), maxLines: 2, overflow: TextOverflow.ellipsis),
            ]
          ],
        ),
      ),
    );
  }

  // --- Build Card for Usage Entry ---
  Widget _buildUsageCard(BuildContext context) {
    final theme = Theme.of(context);
    final DateFormat formatter = DateFormat('MMM d, HH:mm'); // Include time
    final emojis = ['?', '😞', '😕', '😐', '😊', '😄']; // Index 0 for null/invalid

    List<Widget> detailChips = [];
    if(entry.usageAmount != null) detailChips.add(Chip(label: Text(entry.usageAmount!), visualDensity: VisualDensity.compact, labelStyle: theme.textTheme.labelSmall, padding: EdgeInsets.zero));
    if(entry.usageType != null) detailChips.add(Chip(label: Text(entry.usageType!), visualDensity: VisualDensity.compact, labelStyle: theme.textTheme.labelSmall, padding: EdgeInsets.zero));
    if(entry.usagePotency != null) detailChips.add(Chip(label: Text(entry.usagePotency!), visualDensity: VisualDensity.compact, labelStyle: theme.textTheme.labelSmall, padding: EdgeInsets.zero));


    return Card(
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row( // Header: Date/Time and Mood
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatter.format(entry.date), style: theme.textTheme.bodySmall),
                Text(emojis[entry.moodRatingUsage ?? 0], style: const TextStyle(fontSize: 20)),
              ],
            ),
            const Divider(height: 12),
            Wrap(spacing: 6, runSpacing: 4, children: detailChips), // Amount/Type/Potency
            if (entry.usageEffects != null && entry.usageEffects!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(spacing: 6, runSpacing: 4, children: entry.usageEffects!.map((effect) => Chip(label: Text(effect), padding: EdgeInsets.zero, visualDensity: VisualDensity.compact, labelStyle: theme.textTheme.labelSmall, backgroundColor: theme.colorScheme.tertiaryContainer.withOpacity(0.7))).toList()),
            ],
            if (entry.notes.isNotEmpty)...[
              const SizedBox(height: 6),
              Text('Notes: ${entry.notes}', style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic), maxLines: 2, overflow: TextOverflow.ellipsis),
            ]
          ],
        ),
      ),
    );
  }

  // --- Build Card for Abstinence Entry ---
  Widget _buildAbstinenceCard(BuildContext context) {
    final theme = Theme.of(context);
    final DateFormat formatter = DateFormat('MMM d, yyyy');

    return Card(
      elevation: 1.5,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.6), // Slightly different background
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formatter.format(entry.date), style: theme.textTheme.bodySmall), // Header: Date only
            const Divider(height: 12),
            Text('Usage Today: No', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            if (entry.cravingsPresentAbstinence != null)
              Text('Cravings: ${entry.cravingsPresentAbstinence! ? "Yes" : "No"}', style: theme.textTheme.bodyMedium),
            if (entry.notes.isNotEmpty)...[
              const SizedBox(height: 6),
              Text('Notes: ${entry.notes}', style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic), maxLines: 2, overflow: TextOverflow.ellipsis),
            ]
          ],
        ),
      ),
    );
  }
}