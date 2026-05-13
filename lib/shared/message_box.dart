import 'package:flutter/material.dart';

enum MessageBoxType { neutral, success, error }

class MessageBox extends StatelessWidget {
  const MessageBox({
    required this.message,
    this.type = MessageBoxType.neutral,
    super.key,
  });

  final String message;
  final MessageBoxType type;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (background, foreground) = switch (type) {
      MessageBoxType.success => (
        colors.tertiaryContainer,
        colors.onTertiaryContainer,
      ),
      MessageBoxType.error => (colors.errorContainer, colors.onErrorContainer),
      MessageBoxType.neutral => (
        colors.surfaceContainerHighest,
        colors.onSurface,
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: foreground,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
