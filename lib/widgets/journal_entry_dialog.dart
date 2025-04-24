// lib/widgets/journal_entry_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart'; // For generating IDs
import '../models/journal_entry.dart';

// Universal dialog for adding any type of journal entry
Future<JournalEntry?> showJournalEntryDialog(BuildContext context, {required bool isOnBreak}) async {

  // Show different dialog content based on break status
  if (isOnBreak) {
    return _showCheckInDialog(context);
  } else {
    return _showPostBreakDialog(context);
  }
}

// --- Dialog for Daily Check-in (During Break) ---
Future<JournalEntry?> _showCheckInDialog(BuildContext context) async {
  final theme = Theme.of(context);
  final notesController = TextEditingController();
  int selectedMood = 3; // Default to neutral (1-5)
  bool cravings = false;
  List<String> changes = []; // Store selected +/- changes
  final List<String> positiveChanges = ['+ Clear Mind', '+ Better Sleep', '+ More Energy'];
  final List<String> negativeChanges = ['- Irritability', '- Anxiety', '- Headache'];

  return showDialog<JournalEntry>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Daily Check-in'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text('How\'s your mood today?', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row( // Use Emojis for mood rating
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(5, (index) {
                      final rating = index + 1;
                      final emojis = ['😞', '😕', '😐', '😊', '😄'];
                      return IconButton(
                        icon: Text(emojis[index], style: TextStyle(fontSize: 24, color: selectedMood == rating ? theme.colorScheme.primary : null)),
                        isSelected: selectedMood == rating,
                        onPressed: () => setStateDialog(() => selectedMood = rating),
                        // Visual density/padding for tighter spacing
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(), // Remove default padding
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Text('Any cravings today?', style: theme.textTheme.titleMedium),
                  SwitchListTile(
                    title: const Text('Cravings present?'),
                    value: cravings,
                    onChanged: (val) => setStateDialog(() => cravings = val),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  Text('Changes noticed? (Optional)', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap( // Chips for common changes
                    spacing: 8.0, runSpacing: 4.0,
                    children: [
                      ...positiveChanges.map((change) => FilterChip(label: Text(change), selected: changes.contains(change), onSelected: (sel) => setStateDialog(() => sel ? changes.add(change) : changes.remove(change)))),
                      ...negativeChanges.map((change) => FilterChip(label: Text(change), selected: changes.contains(change), onSelected: (sel) => setStateDialog(() => sel ? changes.add(change) : changes.remove(change)))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Notes (Optional)'), maxLines: 2),
                ],
              ),
            ),
            actions: [
              TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(ctx).pop()),
              FilledButton(
                child: const Text('Save Check-in'),
                onPressed: () {
                  final entry = JournalEntry(
                    id: const Uuid().v4(), // Generate unique ID
                    date: DateTime.now(),
                    entryType: JournalEntryType.checkIn,
                    moodRating: selectedMood,
                    cravingsPresentCheckin: cravings,
                    changesNoticed: changes.isNotEmpty ? changes : null,
                    notes: notesController.text.trim(),
                  );
                  Navigator.of(ctx).pop(entry);
                },
              ),
            ],
          );
        });
      });
}


// --- Dialog for Post-Break Tracking ---
Future<JournalEntry?> _showPostBreakDialog(BuildContext context) async {
  final theme = Theme.of(context);
  bool? usageToday; // Start undetermined

  // Show initial Yes/No dialog first
  usageToday = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Track Experience'),
        content: const Text('Did you use cannabis today?'),
        actions: [
          TextButton(child: const Text('No'), onPressed: () => Navigator.of(ctx).pop(false)), // Return false
          FilledButton(child: const Text('Yes'), onPressed: () => Navigator.of(ctx).pop(true)), // Return true
        ],
      ));

  // If user cancelled the first dialog, return null
  if (usageToday == null) return null;

  // Show specific dialog based on Yes/No answer
  if (usageToday) {
    return _showUsageLogDialog(context); // Dialog for logging usage details
  } else {
    return _showAbstinenceLogDialog(context); // Dialog for logging non-usage day
  }
}

// --- Sub-Dialog for Logging Usage Details (Post-Break, Yes) ---
Future<JournalEntry?> _showUsageLogDialog(BuildContext context) async {
  final theme = Theme.of(context);
  final notesController = TextEditingController();
  String selectedAmount = 'Low';
  String? selectedType;
  String? selectedPotency;
  int selectedMood = 3; // 1-5
  List<String> effects = [];
  final List<String> commonEffects = ['Relaxed', 'Creative', 'Focused', 'Social', 'Sleepy', 'Uplifted', 'Anxious', 'Paranoid'];
  final List<String> typeOptions = ['Flower', 'Vape', 'Edible', 'Concentrate', 'Other'];
  final List<String> potencyOptions = ['Low', 'Medium', 'High'];

  return showDialog<JournalEntry>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(builder: (context, setStateDialog){
      return AlertDialog(
        title: const Text('Log Experience Details'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              // Amount Used
              Text('Amount:', style: theme.textTheme.titleMedium),
              Wrap(spacing: 8, children: [
                ChoiceChip(label: const Text('Low'), selected: selectedAmount == 'Low', onSelected: (sel) => setStateDialog(() => selectedAmount = 'Low')),
                ChoiceChip(label: const Text('Medium'), selected: selectedAmount == 'Medium', onSelected: (sel) => setStateDialog(() => selectedAmount = 'Medium')),
                ChoiceChip(label: const Text('High'), selected: selectedAmount == 'High', onSelected: (sel) => setStateDialog(() => selectedAmount = 'High')),
              ]),
              const SizedBox(height: 16),
              // Type (Optional)
              Text('Type (Optional):', style: theme.textTheme.titleMedium),
              Wrap(spacing: 8, children: typeOptions.map((t) => FilterChip(label: Text(t), selected: selectedType == t, onSelected: (sel) => setStateDialog(() => selectedType = sel ? t : null))).toList()),
              const SizedBox(height: 16),
              // Potency (Optional)
              Text('Strength Guess (Optional):', style: theme.textTheme.titleMedium),
              Wrap(spacing: 8, children: potencyOptions.map((p) => FilterChip(label: Text(p), selected: selectedPotency == p, onSelected: (sel) => setStateDialog(() => selectedPotency = sel ? p : null))).toList()),
              const SizedBox(height: 16),
              // Mood While Using
              Text('Mood During/After:', style: theme.textTheme.titleMedium),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: List.generate(5, (i) => IconButton(icon: Text(['😞','😕','😐','😊','😄'][i], style: TextStyle(fontSize: 24, color: selectedMood == i+1 ? theme.colorScheme.primary : null)), isSelected: selectedMood == i+1, onPressed: () => setStateDialog(() => selectedMood = i+1), visualDensity: VisualDensity.compact, padding: EdgeInsets.zero, constraints: const BoxConstraints()))),
              const SizedBox(height: 16),
              // Effects (Optional)
              Text('Effects Noticed (Optional):', style: theme.textTheme.titleMedium),
              Wrap(spacing: 8, runSpacing: 4, children: commonEffects.map((e) => FilterChip(label: Text(e), selected: effects.contains(e), onSelected: (sel) => setStateDialog(() => sel ? effects.add(e) : effects.remove(e)))).toList()),
              const SizedBox(height: 16),
              // Notes
              TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Notes (Optional)', hintText: 'Strain, specific feelings...'), maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(ctx).pop()),
          FilledButton(
            child: const Text('Save Experience'),
            onPressed: () {
              final entry = JournalEntry(
                id: const Uuid().v4(),
                date: DateTime.now(),
                entryType: JournalEntryType.usage,
                usageAmount: selectedAmount,
                usageType: selectedType,
                usagePotency: selectedPotency,
                moodRatingUsage: selectedMood,
                usageEffects: effects.isNotEmpty ? effects : null,
                notes: notesController.text.trim(),
              );
              Navigator.of(ctx).pop(entry);
            },
          ),
        ],
      );
    }),
  );
}

// --- Sub-Dialog for Logging Abstinence Day (Post-Break, No) ---
Future<JournalEntry?> _showAbstinenceLogDialog(BuildContext context) async {
  final theme = Theme.of(context);
  final notesController = TextEditingController();
  bool cravings = false; // Default no

  return showDialog<JournalEntry>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(builder: (context, setStateDialog) {
      return AlertDialog(
        title: const Text('Log Non-Use Day'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text('Notice any cravings today?', style: theme.textTheme.titleMedium),
              Row( // Use buttons for Yes/No
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ChoiceChip(label: const Text('No'), selected: !cravings, onSelected: (sel) => setStateDialog(() => cravings = false), visualDensity: VisualDensity.compact,),
                    const SizedBox(width: 8),
                    ChoiceChip(label: const Text('Yes'), selected: cravings, onSelected: (sel) => setStateDialog(() => cravings = true), visualDensity: VisualDensity.compact,),
                  ]
              ),
              const SizedBox(height: 16),
              TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Notes (Optional)', hintText: 'How did you feel?...'), maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(ctx).pop()),
          FilledButton(
            child: const Text('Save Entry'),
            onPressed: () {
              final entry = JournalEntry(
                id: const Uuid().v4(),
                date: DateTime.now(),
                entryType: JournalEntryType.abstinence,
                cravingsPresentAbstinence: cravings,
                notes: notesController.text.trim(),
              );
              Navigator.of(ctx).pop(entry);
            },
          ),
        ],
      );
    }),
  );
}