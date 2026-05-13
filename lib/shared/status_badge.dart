import 'package:flutter/material.dart';

enum StatusBadgeType { paid, debt }

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.label, required this.type, super.key});

  final String label;
  final StatusBadgeType type;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isPaid = type == StatusBadgeType.paid;
    final background =
        isPaid ? colors.tertiaryContainer : colors.errorContainer;
    final foreground =
        isPaid ? colors.onTertiaryContainer : colors.onErrorContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isPaid ? colors.tertiary : colors.error,
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
