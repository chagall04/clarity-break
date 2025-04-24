import 'package:flutter/material.dart';

/// A button that subtly scales on press for extra polish.
/// Wrap your existing buttons or use in place of raw GestureDetector.
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Duration duration;
  const AnimatedButton({
    required this.child,
    required this.onTap,
    this.duration = const Duration(milliseconds: 100),
    super.key,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _pressed = false;

  void _onTapDown(TapDownDetails _) => setState(() => _pressed = true);
  void _onTapUp(TapUpDetails _) {
    setState(() => _pressed = false);
    widget.onTap();
  }

  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: widget.duration,
        child: widget.child,
      ),
    );
  }
}
