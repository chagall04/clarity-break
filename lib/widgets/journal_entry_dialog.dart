// lib/widgets/journal_entry_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/journal_entry.dart';

Future<JournalEntry?> showJournalEntryDialog(BuildContext context, {required bool isOnBreak}) async {
  if (isOnBreak) {
    return _showCheckInDialog(context);
  } else {
    return _showPostBreakDialog(context);
  }
}

Future<JournalEntry?> _showCheckInDialog(BuildContext context) async {
  final theme = Theme.of(context);
  final notesController = TextEditingController();
  int selectedMood = 3;
  bool cravings = false;
  List<String> changes = [];
  final commonChanges = [
    '✨ Clearer Mind', '⚡ More Energy', '😴 Better Sleep', '😊 Better Mood', '🎯 More Focus',
    '😠 Irritability', '😥 Anxiety', '🤕 Headache', '🥱 Fatigue', '🌫️ Brain Fog', '💤 Sleep Difficulty',
    '💭 Vivid Dreams'
  ];

  return showDialog<JournalEntry>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(builder: (context, setStateDialog) {
      return AlertDialog(
        title: const Text('Daily Check-in'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How\'s your mood today?', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (i) {
                  final rating = i + 1;
                  final emojis = ['😞','😕','😐','😊','😄'];
                  return IconButton(
                    icon: Text(emojis[i], style: TextStyle(fontSize: 24, color: selectedMood == rating ? theme.colorScheme.primary : null)),
                    onPressed: () => setStateDialog(() => selectedMood = rating),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  );
                }),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text('Any cravings today?', style: theme.textTheme.titleMedium),
                value: cravings,
                onChanged: (val) => setStateDialog(() => cravings = val),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              Text('Changes noticed? (Optional)', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: commonChanges.map((change) {
                  return FilterChip(
                    label: Text(change),
                    selected: changes.contains(change),
                    onSelected: (sel) {
                      setStateDialog(() {
                        sel ? changes.add(change) : changes.remove(change);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes (Optional)'),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          FilledButton(
            child: const Text('Save Check-in'),
            onPressed: () {
              HapticFeedback.lightImpact();
              final entry = JournalEntry(
                id: const Uuid().v4(),
                date: DateTime.now(),
                entryType: JournalEntryType.checkIn,
                moodRating: selectedMood,
                cravingsPresentCheckin: cravings,
                changesNoticed: changes.isEmpty ? null : List.from(changes),
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

Future<JournalEntry?> _showPostBreakDialog(BuildContext context) async {
  final usageToday = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('Track Experience'),
      content: const Text('Did you use cannabis today?'),
      actions: [
        TextButton(child: const Text('No'), onPressed: () => Navigator.of(ctx).pop(false)),
        FilledButton(child: const Text('Yes'), onPressed: () => Navigator.of(ctx).pop(true)),
      ],
    ),
  );
  if (usageToday == null) return null;
  if (usageToday) {
    return _showUsageLogDialog(context);
  } else {
    return _showAbstinenceLogDialog(context);
  }
}

Future<JournalEntry?> _showUsageLogDialog(BuildContext context) async {
  final theme = Theme.of(context);
  final notesController = TextEditingController();
  String selectedAmount = 'Low';
  String? selectedType;
  String? selectedPotency;
  int selectedMood = 3;
  List<String> selectedEffectKeys = [];
  final commonEffectsWithEmojis = {
    '😊 Relaxed': 'Relaxed', '✨ Creative': 'Creative', '🎯 Focused': 'Focused',
    '💬 Social': 'Social', '😴 Sleepy': 'Sleepy', '☀️ Uplifted': 'Uplifted',
    '😟 Anxious': 'Anxious', '😵‍💫 Paranoid': 'Paranoid', '🍔 Hungry': 'Hungry',
  };
  final typeOptions = ['Flower','Vape','Edible','Concentrate','Other'];
  final potencyOptions = ['Low','Medium','High'];

  return showDialog<JournalEntry>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(builder: (context, setStateDialog) {
      return AlertDialog(
        title: const Text('Log Experience Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Amount:', style: theme.textTheme.titleMedium),
              Wrap(spacing: 8, children: [
                ChoiceChip(label: const Text('Low'), selected: selectedAmount == 'Low', onSelected: (sel) => setStateDialog(() => selectedAmount = 'Low')),
                ChoiceChip(label: const Text('Medium'), selected: selectedAmount == 'Medium', onSelected: (sel) => setStateDialog(() => selectedAmount = 'Medium')),
                ChoiceChip(label: const Text('High'), selected: selectedAmount == 'High', onSelected: (sel) => setStateDialog(() => selectedAmount = 'High')),
              ]),
              const SizedBox(height: 16),
              Text('Type (Optional):', style: theme.textTheme.titleMedium),
              Wrap(
                spacing: 8,
                children: typeOptions.map((t) {
                  return FilterChip(
                    label: Text(t),
                    selected: selectedType == t,
                    onSelected: (sel) => setStateDialog(() => selectedType = sel ? t : null),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text('Strength Guess (Optional):', style: theme.textTheme.titleMedium),
              Wrap(
                spacing: 8,
                children: potencyOptions.map((p) {
                  return FilterChip(
                    label: Text(p),
                    selected: selectedPotency == p,
                    onSelected: (sel) => setStateDialog(() => selectedPotency = sel ? p : null),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text('Mood During/After:', style: theme.textTheme.titleMedium),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (i) {
                  return IconButton(
                    icon: Text(['😞','😕','😐','😊','😄'][i], style: TextStyle(fontSize: 24, color: selectedMood == i+1 ? theme.colorScheme.primary : null)),
                    onPressed: () => setStateDialog(() => selectedMood = i+1),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Text('Effects Noticed (Optional):', style: theme.textTheme.titleMedium),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: commonEffectsWithEmojis.keys.map((effectKey) {
                  return FilterChip(
                    label: Text(effectKey),
                    selected: selectedEffectKeys.contains(effectKey),
                    onSelected: (sel) {
                      setStateDialog(() {
                        sel ? selectedEffectKeys.add(effectKey) : selectedEffectKeys.remove(effectKey);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes (Optional)', hintText: 'Strain, specific feelings...'),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(ctx).pop()),
          FilledButton(
            child: const Text('Save Experience'),
            onPressed: () {
              HapticFeedback.lightImpact();
              final entry = JournalEntry(
                id: const Uuid().v4(),
                date: DateTime.now(),
                entryType: JournalEntryType.usage,
                usageAmount: selectedAmount,
                usageType: selectedType,
                usagePotency: selectedPotency,
                moodRatingUsage: selectedMood,
                usageEffects: selectedEffectKeys.isEmpty ? null : List.from(selectedEffectKeys),
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

Future<JournalEntry?> _showAbstinenceLogDialog(BuildContext context) async {
  final theme = Theme.of(context);
  final notesController = TextEditingController();
  bool cravings = false;

  return showDialog<JournalEntry>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(builder: (context, setStateDialog) {
      return AlertDialog(
        title: const Text('Log Non-Use Day'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notice any cravings today?', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(label: const Text('No'), selected: !cravings, onSelected: (sel) => setStateDialog(() => cravings = false)),
                const SizedBox(width: 8),
                ChoiceChip(label: const Text('Yes'), selected: cravings, onSelected: (sel) => setStateDialog(() => cravings = true)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes (Optional)', hintText: 'How did you feel?...'),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(ctx).pop()),
          FilledButton(
            child: const Text('Save Entry'),
            onPressed: () {
              HapticFeedback.lightImpact();
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
