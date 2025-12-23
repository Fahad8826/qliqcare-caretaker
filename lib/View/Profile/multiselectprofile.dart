
import 'package:flutter/material.dart';

class MultiSelect<T> extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final List<T> selected;
  final Function(List<T>) onChange;

  const MultiSelect({
    super.key,
    required this.title,
    required this.items,
    required this.selected,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),

        Wrap(
          spacing: 8,
          children: items.map((item) {
            final T id = item["id"] as T;
            final String label = item["label"];
            final bool isSelected = selected.contains(id);

            return FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (value) {
                final updated = List<T>.from(selected);
                value ? updated.add(id) : updated.remove(id);

                debugPrint("🔘 $title updated: $updated");
                onChange(updated);
              },
            );
          }).toList(),
        )
      ],
    );
  }
}
