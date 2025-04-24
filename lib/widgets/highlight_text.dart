// lib/widgets/highlight_text.dart
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class HighlightText extends StatelessWidget {
  final String text, query;
  final TextStyle? style, highlightStyle;

  const HighlightText({
    required this.text,
    required this.query,
    this.style,
    this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) return Text(text, style: style);
    final lcText = text.toLowerCase();
    final lcQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;
    while (true) {
      final idx = lcText.indexOf(lcQuery, start);
      if (idx < 0) {
        spans.add(TextSpan(text: text.substring(start), style: style));
        break;
      }
      if (idx > start) spans.add(TextSpan(text: text.substring(start, idx), style: style));
      spans.add(TextSpan(
          text: text.substring(idx, idx + query.length),
          style: highlightStyle ?? style?.copyWith(backgroundColor: Colors.yellow)));
      start = idx + query.length;
    }
    return RichText(text: TextSpan(children: spans));
  }
}
