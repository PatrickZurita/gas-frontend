import 'package:flutter/material.dart';

import 'summary_card.dart';

class InfoField extends StatelessWidget {
  const InfoField({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SummaryCard(
      borderRadius: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.labelLarge),
          const SizedBox(height: 4),
          Text(
            value,
            style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
