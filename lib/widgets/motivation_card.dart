// lib/widgets/motivation_card.dart
import 'package:flutter/material.dart';

class MotivationCard extends StatelessWidget {
  final String message; // The motivational message/tip

  const MotivationCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      // Using CardTheme defined in main.dart
      // elevation: 2.0, // Defined in CardTheme
      // shape: RoundedRectangleBorder( // Defined in CardTheme
      //   borderRadius: BorderRadius.circular(12.0),
      // ),
      // color: theme.colorScheme.surface, // Defined in CardTheme
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.lightbulb_outline, // Or Icons.star_border, Icons.check_circle_outline
              color: theme.colorScheme.secondary, // Muted Green
              size: 28.0,
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }
}