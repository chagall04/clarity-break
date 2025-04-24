// lib/widgets/progress_ring.dart
import 'package:flutter/material.dart';
import 'dart:math' as math; // Needed for pi calculation

// Animated progress ring widget
class ProgressRing extends StatefulWidget {
  final double progress; // Target progress (0.0 to 1.0)
  final int currentDay;
  final int totalDays;
  final Duration duration; // Animation duration

  const ProgressRing({
    super.key,
    required this.progress,
    required this.currentDay,
    required this.totalDays,
    this.duration = const Duration(milliseconds: 800), // Default animation duration
  });

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with SingleTickerProviderStateMixin { // Mixin for AnimationController vsync
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentAnimatedProgress = 0.0; // Tracks the animated value

  @override
  void initState() {
    super.initState();
    // Initialize the AnimationController
    _controller = AnimationController(
      duration: widget.duration, // Use duration passed from widget
      vsync: this, // Required by the mixin
    );

    // Create a Tween animation from 0.0 to the target progress
    _updateAnimation(0.0, widget.progress); // Initial animation setup

    // Start the animation
    _controller.forward();
  }

  // Helper to update the animation when the target progress changes
  void _updateAnimation(double oldTarget, double newTarget) {
    // Create a curved animation for smoother easing (e.g., easeInOut)
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    // Create a Tween to animate between the *current animated value* and the new target
    _animation = Tween<double>(begin: _currentAnimatedProgress, end: newTarget.clamp(0.0, 1.0))
        .animate(_animation)
      ..addListener(() {
        // Update the state whenever the animation value changes
        setState(() {
          _currentAnimatedProgress = _animation.value;
        });
      });
  }


  @override
  void didUpdateWidget(ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the target progress changes, update and restart the animation
    if (oldWidget.progress != widget.progress) {
      _updateAnimation(_currentAnimatedProgress, widget.progress); // Update animation target
      _controller.reset(); // Reset controller
      _controller.forward(); // Start animation towards new target
    }
    // Also update duration if it changes
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose controller to free resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AspectRatio(
      aspectRatio: 1.0, // Maintain square shape
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the ring
        child: CustomPaint(
          // Use the *animated* progress value for the painter
          painter: _RingPainter(
            progress: _currentAnimatedProgress,
            foregroundColor: theme.colorScheme.primary, // Teal
            backgroundColor: theme.colorScheme.primary.withOpacity(0.2), // Lighter teal
            strokeWidth: 15.0,
          ),
          // Center text content remains the same
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Day',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Text(
                  '${widget.currentDay}', // Use widget.currentDay
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  '/ ${widget.totalDays}', // Use widget.totalDays
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
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

// Custom Painter to draw the ring (remains largely the same, uses passed progress)
class _RingPainter extends CustomPainter {
  final double progress; // Current animated progress (0.0 to 1.0)
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
    const startAngle = -math.pi / 2; // Start drawing from the top center
    final sweepAngle = 2 * math.pi * progress; // Calculate angle based on progress

    // Define paint for the background ring track
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke // Draw only the stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // Use rounded ends

    // Define paint for the foreground progress arc
    final foregroundPaint = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // Use rounded ends

    // Draw the background circle first
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw the progress arc over the background
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius), // Define drawing area
      startAngle, // Start angle (top)
      sweepAngle, // Angle to sweep based on progress
      false, // Draw arc only, not connecting to center
      foregroundPaint, // Use foreground paint settings
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    // Repaint only if the animated progress value or appearance changes
    return oldDelegate.progress != progress ||
        oldDelegate.foregroundColor != foregroundColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}