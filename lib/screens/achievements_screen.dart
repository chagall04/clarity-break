// lib/screens/achievements_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/achievement_provider.dart';
import '../models/achievement.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _stagger;

  @override
  void initState() {
    super.initState();
    _stagger = AnimationController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final badges = context.read<AchievementProvider>().badges;
      // duration = count * 100 + base
      _stagger.duration = Duration(milliseconds: badges.length * 100 + 300);
      _stagger.forward();
    });
  }

  @override
  void dispose() {
    _stagger.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badges = context.watch<AchievementProvider>().badges;
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: badges.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 1, mainAxisSpacing: 16, crossAxisSpacing: 16),
        itemBuilder: (context, i) {
          final badge = badges[i];
          final start = i * 0.1;
          final end = start + 0.5;
          final anim = CurvedAnimation(
            parent: _stagger,
            curve: Interval(start, end, curve: Curves.easeOut),
          );
          return FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1).animate(anim),
              child: _BadgeTile(badge: badge),
            ),
          );
        },
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final Achievement badge;
  const _BadgeTile({required this.badge});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = badge.unlocked
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withOpacity(0.3);
    return Column(
      children: [
        Expanded(
          child: Opacity(
            opacity: badge.unlocked ? 1.0 : 0.5,
            child: Image.asset(
              badge.iconAsset,
              fit: BoxFit.contain,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          badge.title,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: badge.unlocked
                ? theme.colorScheme.onBackground
                : theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: badge.unlocked ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
