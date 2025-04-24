// lib/widgets/journal_entry_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';         // For date formatting
import '../models/journal_entry.dart'; // The data model for entries

// A reusable widget to display a single journal entry in a Card format.
// It adapts its appearance based on the entry type (checkIn, usage, abstinence).
class JournalEntryCard extends StatelessWidget {
  final JournalEntry entry; // The journal entry data to display

  // Constructor requiring the entry data
  const JournalEntryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    // Use a switch statement to call the appropriate build method based on entry type
    switch (entry.entryType) {
      case JournalEntryType.checkIn:
        return _buildCheckInCard(context); // Build card for daily check-in
      case JournalEntryType.usage:
        return _buildUsageCard(context);   // Build card for usage tracking
      case JournalEntryType.abstinence:
        return _buildAbstinenceCard(context); // Build card for non-use day
    }
  }

  // --- Build Card Layout for Check-in Entry ---
  Widget _buildCheckInCard(BuildContext context) {
    final theme = Theme.of(context); // Access theme data
    final DateFormat formatter = DateFormat('MMM d, yyyy'); // Date format
    // Emojis corresponding to mood ratings 1-5 (index 0 is fallback for null/invalid)
    final emojis = ['?', '😞', '😕', '😐', '😊', '😄'];

    return Card(
      elevation: 1.5, // Subtle shadow
      // Inherits shape, color, margin from CardTheme in main.dart
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Padding inside the card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align content left
          children: [
            // --- Header Row: Date and Mood Emoji ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatter.format(entry.date), style: theme.textTheme.labelLarge), // Use slightly bolder label for date
                Text(emojis[entry.moodRating ?? 0], style: const TextStyle(fontSize: 24)), // Larger emoji display
              ],
            ),
            const Divider(height: 12, thickness: 0.5), // Thinner visual separator

            // --- Cravings Status ---
            if (entry.cravingsPresentCheckin != null)
              Row( // Use Row for Icon + Text alignment
                crossAxisAlignment: CrossAxisAlignment.center, // Center icon vertically with text
                children: [
                  Icon(Icons.whatshot_outlined, size: 16, color: theme.colorScheme.secondary.withOpacity(0.8)), // Cravings icon
                  const SizedBox(width: 6), // Spacing
                  Text('Cravings: ${entry.cravingsPresentCheckin! ? "Yes" : "No"}', style: theme.textTheme.bodyMedium),
                ],
              ),

            // --- Changes Noticed Chips ---
            if (entry.changesNoticed != null && entry.changesNoticed!.isNotEmpty) ...[
              // Add vertical space only if cravings were shown
              if (entry.cravingsPresentCheckin != null) const SizedBox(height: 6),
              Row( // Use Row for Icon + Wrapped Chips
                crossAxisAlignment: CrossAxisAlignment.start, // Align icon to the top of the wrap
                children: [
                  Padding( // Add slight padding to align icon better
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Icon(Icons.checklist_rtl_outlined, size: 16, color: theme.colorScheme.secondary.withOpacity(0.8)), // Changes icon
                  ),
                  const SizedBox(width: 6), // Spacing
                  Expanded( // Allow chips to wrap within the available space
                    child: Wrap(
                        spacing: 6, // Horizontal space between chips
                        runSpacing: 4, // Vertical space between chip rows
                        children: entry.changesNoticed!.map((change) => Chip(
                            label: Text(change),
                            // Use theme's default chip styling defined in main.dart
                            // Adjust specific properties if needed:
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            labelStyle: theme.textTheme.labelSmall
                        )).toList()),
                  ),
                ],
              ),
            ],

            // --- Notes Section ---
            if (entry.notes.isNotEmpty)...[
              // Add vertical space only if cravings OR changes were shown
              if (entry.cravingsPresentCheckin != null || (entry.changesNoticed != null && entry.changesNoticed!.isNotEmpty))
                const SizedBox(height: 8),
              Row( // Use Row for Icon + Text alignment
                crossAxisAlignment: CrossAxisAlignment.start, // Align icon top
                children: [
                  Padding( // Add padding to align icon
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Icon(Icons.notes_outlined, size: 16, color: theme.colorScheme.secondary.withOpacity(0.8)), // Notes icon
                  ),
                  const SizedBox(width: 6), // Spacing
                  Expanded( // Allow notes text to wrap
                    child: Text(
                        entry.notes,
                        style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: theme.colorScheme.onSurface.withOpacity(0.8)) // Italicize notes
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  // --- Build Card Layout for Usage Entry ---
  Widget _buildUsageCard(BuildContext context) {
    final theme = Theme.of(context); // Access theme data
    final DateFormat formatter = DateFormat('MMM d, HH:mm'); // Include time for usage logs
    // Emojis for mood ratings
    final emojis = ['?', '😞', '😕', '😐', '😊', '😄'];

    // Create a list of detail chips (Amount, Type, Potency) if they exist
    List<Widget> detailChips = [];
    // Helper function to add chip if value is not null
    void addDetailChip(String? label) {
      if (label != null && label.isNotEmpty) {
        detailChips.add(Chip(
          label: Text(label),
          visualDensity: VisualDensity.compact,
          labelStyle: theme.textTheme.labelSmall,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          // Use surfaceVariant color from theme for these detail chips
          backgroundColor: theme.colorScheme.surfaceVariant,
        ));
      }
    }
    addDetailChip(entry.usageAmount);    // Add Amount chip
    addDetailChip(entry.usageType);      // Add Type chip (if exists)
    addDetailChip(entry.usagePotency);   // Add Potency chip (if exists)


    return Card(
      elevation: 1.5, // Subtle shadow
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Padding inside card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align content left
          children: [
            // --- Header Row: Date/Time and Mood Emoji ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatter.format(entry.date), style: theme.textTheme.labelLarge), // Date/Time
                Text(emojis[entry.moodRatingUsage ?? 0], style: const TextStyle(fontSize: 24)), // Mood Emoji
              ],
            ),
            const Divider(height: 12, thickness: 0.5), // Separator

            // --- Detail Chips Row ---
            if (detailChips.isNotEmpty) // Only show Wrap if there are chips
              Wrap(spacing: 6, runSpacing: 4, children: detailChips), // Display Amount/Type/Potency chips

            // --- Effects Chips ---
            if (entry.usageEffects != null && entry.usageEffects!.isNotEmpty) ...[
              const SizedBox(height: 6), // Spacing if detail chips were present
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Icon(Icons.spa_outlined, size: 16, color: theme.colorScheme.tertiary.withOpacity(0.9)), // Effects icon
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Wrap(spacing: 6, runSpacing: 4, children: entry.usageEffects!.map((effect) => Chip(
                        label: Text(effect),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        labelStyle: theme.textTheme.labelSmall,
                        // Use tertiary color for effects chips
                        backgroundColor: theme.colorScheme.tertiaryContainer.withOpacity(0.7)
                    )).toList()),
                  ),
                ],
              ),
            ],

            // --- Notes Section ---
            if (entry.notes.isNotEmpty)...[
              // Add vertical space only if detail OR effect chips were shown
              if (detailChips.isNotEmpty || (entry.usageEffects != null && entry.usageEffects!.isNotEmpty))
                const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Icon(Icons.notes_outlined, size: 16, color: theme.colorScheme.secondary.withOpacity(0.8)), // Notes icon
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                        entry.notes,
                        style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: theme.colorScheme.onSurface.withOpacity(0.8))
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  // --- Build Card Layout for Abstinence Entry ---
  Widget _buildAbstinenceCard(BuildContext context) {
    final theme = Theme.of(context); // Access theme data
    final DateFormat formatter = DateFormat('MMM d, yyyy'); // Date format

    return Card(
      elevation: 1.0, // Slightly less elevation?
      // Use a distinct background color to differentiate abstinence days
      color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Padding inside card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align content left
          children: [
            // --- Header Row: Date and Status Icon ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatter.format(entry.date), style: theme.textTheme.labelLarge), // Date
                Icon(Icons.check_circle_outline, color: theme.colorScheme.secondary, size: 20), // Icon indicating non-use day
              ],
            ),
            const Divider(height: 12, thickness: 0.5), // Separator

            // --- Main Info ---
            Text('Usage Today: No', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)), // Confirmation text
            // Display Cravings Status if logged
            if (entry.cravingsPresentAbstinence != null) ... [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.whatshot_outlined, size: 16, color: theme.colorScheme.secondary.withOpacity(0.8)),
                  const SizedBox(width: 6),
                  Text('Cravings: ${entry.cravingsPresentAbstinence! ? "Yes" : "No"}', style: theme.textTheme.bodyMedium),
                ],
              ),
            ],
            // Display Notes if entered
            if (entry.notes.isNotEmpty)...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Icon(Icons.notes_outlined, size: 16, color: theme.colorScheme.secondary.withOpacity(0.8)),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                        entry.notes,
                        style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: theme.colorScheme.onSurface.withOpacity(0.8))
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
} // End of JournalEntryCard class