import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    required this.label,
    required this.value,
    this.primary = false,
    super.key,
  });

  final String label;
  final String value;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.all(primary ? 16 : 12),
      decoration: BoxDecoration(
        color:
            primary ? colors.primaryContainer : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: (primary ? text.titleMedium : text.bodyMedium)?.copyWith(
              fontWeight: primary ? FontWeight.w700 : FontWeight.w500,
              color:
                  primary ? colors.onPrimaryContainer : colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: (primary ? text.displaySmall : text.headlineSmall)
                  ?.copyWith(
                    fontWeight: FontWeight.w800,
                    color:
                        primary ? colors.onPrimaryContainer : colors.onSurface,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
