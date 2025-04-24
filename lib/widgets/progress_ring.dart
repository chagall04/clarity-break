// lib/widgets/progress_ring.dart
import 'package:flutter/material.dart';
import 'dart:math' as math; // Needed for pi calculation

// Animated progress ring widget displaying break progress
class ProgressRing extends StatefulWidget {
  final double progress; // Target progress value (0.0 to 1.0)
  final int currentDay; // Day number to display
  final int totalDays;  // Total days in the break (e.g., 28)
  final Duration duration; // Duration of the animation

  const ProgressRing({
    super.key,
    required this.progress,
    required this.currentDay,
    required this.totalDays,
    this.duration = const Duration(milliseconds: 1000), // Slightly longer duration (1 second)
  });

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with SingleTickerProviderStateMixin { // Mixin needed for AnimationController

  late AnimationController _controller; // Controls the animation timing
  late Animation<double> _animation;    // Defines the animation value curve
  double _currentAnimatedProgress = 0.0; // Stores the current value during animation

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the specified duration
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this, // Provides ticker for animation frames
    );

    // Set up the initial animation (from 0 to the initial target progress)
    _updateAnimation(0.0, widget.progress);

    // Start the animation shortly after the widget builds
    // Use addPostFrameCallback for potentially smoother start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(mounted) { // Check if widget is still mounted before starting animation
        _controller.forward();
      }
    });
    // _controller.forward(); // Alternative: start immediately
  }

  // Helper function to create/update the animation tween
  void _updateAnimation(double oldAnimatedValue, double newTarget) {
    // Use a CurvedAnimation for smooth easing (e.g., easeOut, easeInOut)
    final curvedAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo); // Try easeOutExpo for a nice effect

    // Create a Tween that animates from the current animated value to the new target progress
    // Clamp the target to ensure it stays within 0.0 and 1.0
    _animation = Tween<double>(begin: oldAnimatedValue, end: newTarget.clamp(0.0, 1.0))
        .animate(curvedAnimation) // Apply the curve to the tween
      ..addListener(() {
        // Rebuild the widget whenever the animation value changes
        if (mounted) { // Check if widget is mounted before calling setState
          setState(() {
            _currentAnimatedProgress = _animation.value; // Update the animated value
          });
        }
      });
  }


  @override
  void didUpdateWidget(ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the target progress passed to the widget changes...
    if (oldWidget.progress != widget.progress) {
      // Update the animation to target the new progress value
      _updateAnimation(_currentAnimatedProgress, widget.progress);
      // Reset and restart the animation controller
      _controller.forward(from: 0.0); // Restart animation from the beginning
    }
    // Update controller duration if the widget's duration property changes
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Important: Dispose controller to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access theme for colors

    // Build the visual representation
    return AspectRatio(
      aspectRatio: 1.0, // Ensure the widget is square
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the drawing area
        child: CustomPaint(
          // Pass the *current animated progress* value to the painter
          painter: _RingPainter(
            progress: _currentAnimatedProgress,
            foregroundColor: theme.colorScheme.primary, // Use theme's primary color
            backgroundColor: theme.colorScheme.primary.withOpacity(0.2), // Use lighter primary for track
            strokeWidth: 15.0, // Thickness of the ring
          ),
          // Display the day count text in the center
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
                  '${widget.currentDay}', // Display current day number
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary, // Highlight number with primary color
                  ),
                ),
                Text(
                  '/ ${widget.totalDays}', // Display total days
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

// Custom Painter class responsible for drawing the ring (No changes needed here from previous version)
class _RingPainter extends CustomPainter {
  final double progress;
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
    const startAngle = -math.pi / 2; // Start at the top (12 o'clock)
    final sweepAngle = 2 * math.pi * progress; // Calculate sweep based on progress

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final foregroundPaint = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint); // Draw background track
    canvas.drawArc( // Draw progress arc
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    // Repaint if progress or appearance changes
    return oldDelegate.progress != progress ||
        oldDelegate.foregroundColor != foregroundColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}