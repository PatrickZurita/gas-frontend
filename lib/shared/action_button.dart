import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = false,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final style =
        primary
            ? ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(72))
            : OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(64));

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 28),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    if (primary) {
      return ElevatedButton(onPressed: onPressed, style: style, child: child);
    }

    return OutlinedButton(onPressed: onPressed, style: style, child: child);
  }
}
