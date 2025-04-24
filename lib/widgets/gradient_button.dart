import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double height;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final gradient = LinearGradient(
      colors: [cs.primary, cs.secondary],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 8,
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white24,
          child: SizedBox(
            height: height,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
