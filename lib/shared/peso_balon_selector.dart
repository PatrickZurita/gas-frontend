import 'package:flutter/material.dart';

class PesoBalonSelector extends StatelessWidget {
  const PesoBalonSelector({
    required this.value,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final int value;
  final ValueChanged<int>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Peso del balon',
          style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment<int>(
              value: 10,
              label: Text('10 kg'),
              icon: Icon(Icons.propane_tank_outlined),
            ),
            ButtonSegment<int>(
              value: 45,
              label: Text('45 kg'),
              icon: Icon(Icons.propane_tank),
            ),
          ],
          selected: {value},
          onSelectionChanged:
              enabled && onChanged != null
                  ? (selection) => onChanged!(selection.first)
                  : null,
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(const Size.fromHeight(60)),
            textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 20)),
          ),
        ),
      ],
    );
  }
}
