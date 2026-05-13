import 'package:flutter/material.dart';

class CatalogOption {
  const CatalogOption({required this.value, required this.label});

  final String value;
  final String label;
}

class CatalogSelector extends StatelessWidget {
  const CatalogSelector({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    super.key,
  });

  final String label;
  final String value;
  final List<CatalogOption> options;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<String>(
            segments:
                options
                    .map(
                      (o) => ButtonSegment<String>(
                        value: o.value,
                        label: Text(o.label),
                      ),
                    )
                    .toList(),
            selected: {value},
            onSelectionChanged:
                onChanged == null
                    ? null
                    : (selection) => onChanged!(selection.first),
            style: ButtonStyle(
              minimumSize: WidgetStateProperty.all(const Size.fromHeight(56)),
              textStyle: WidgetStateProperty.all(
                text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
