// lib/widgets/tag_filter_row.dart
import 'package:flutter/material.dart';

class TagFilterRow extends StatelessWidget {
  final List<String> tags;
  final String selected;
  final ValueChanged<String> onTagSelected;

  const TagFilterRow({
    required this.tags,
    required this.selected,
    required this.onTagSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ...['All', ...tags].map((tag) {
            final isSel = tag == selected;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(tag),
                selected: isSel,
                onSelected: (_) => onTagSelected(tag),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
