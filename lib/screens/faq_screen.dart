// lib/screens/faq_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  final String _markdown = r'''
# FAQ & User Guide

## How do I start a break?
Tap **Start Clarity Break** on the Home screen, enter your reason (“My Why”) and select a duration.

## How do I log a check-in?
During an active break, the **Daily Check-in** button appears on the Journal tab. Tap it each day to rate mood, note cravings, changes, and add notes.

## How do I track post-break usage?
After your break ends, the Journal button changes to **Track Experience**. Tap it to log usage or non-use, mood, effects, and notes.

## Can I edit or delete entries?
Yes. Long-press an entry to edit, or swipe it to the left to delete. You will be asked to confirm deletion.

## How do notifications work?
Enable daily reminders in Settings. You will get a notification each morning at your chosen time. Reminders automatically reschedule after device reboot.

## Where do I find detailed articles?
Go to the **Library** tab to browse categories and articles on tolerance science, tips, post-break strategies, and more.

## How do I reset my data?
In **Settings**, use **Clear All Data** to wipe history and journal entries. This cannot be undone.
''';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Guide & FAQ'),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Markdown(
          data: _markdown,
          styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
            p: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            h1: theme.textTheme.headlineLarge,
            h2: theme.textTheme.headlineMedium,
          ),
          selectable: true,
        ),
      ),
    );
  }
}
