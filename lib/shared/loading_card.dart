import 'package:flutter/material.dart';

import 'summary_card.dart';

class LoadingCard extends StatelessWidget {
  const LoadingCard({required this.message, this.icon, super.key});

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return SummaryCard(
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 28, color: colors.primary),
            const SizedBox(width: 12),
          ],
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              message,
              style: text.titleMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
