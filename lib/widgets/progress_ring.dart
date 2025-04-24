// lib/widgets/progress_ring.dart
import 'package:flutter/material.dart';
import 'dart:math' as math; // Needed for pi

class ProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int currentDay;
  final int totalDays;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.currentDay,
    required this.totalDays,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Ensure progress doesn't exceed 1.0 for drawing calculation
    final clampedProgress = progress.clamp(0.0, 1.0);

    return AspectRatio(
      aspectRatio: 1.0, // Make it square
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the ring
        child: CustomPaint(
          painter: _RingPainter(
            progress: clampedProgress,
            foregroundColor: theme.colorScheme.primary, // Teal
            backgroundColor: theme.colorScheme.primary.withOpacity(0.2), // Lighter teal background
            strokeWidth: 15.0, // Thickness of the ring
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Day',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
                Text(
                  '$currentDay', // Current day number
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary, // Teal color for number
                  ),
                ),
                Text(
                  '/ $totalDays', // Total days
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Painter to draw the ring
class _RingPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color foregroundColor;
  final Color backgroundColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;
    const startAngle = -math.pi / 2; // Start from the top
    final sweepAngle = 2 * math.pi * progress; // Angle based on progress

    // Paint for the background ring
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // Rounded ends for the background

    // Paint for the foreground (progress) ring
    final foregroundPaint = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // Rounded ends for the progress arc

    // Draw the background circle
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw the progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false, // Do not connect center
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Repaint only if progress or colors change
    final old = oldDelegate as _RingPainter;
    return old.progress != progress ||
        old.foregroundColor != foregroundColor ||
        old.backgroundColor != backgroundColor;
  }
}