import 'package:flutter/material.dart';

class ClienteListTile extends StatelessWidget {
  const ClienteListTile({
    required this.direccion,
    required this.telefono,
    required this.onTap,
    this.recent = false,
    super.key,
  });

  final String direccion;
  final String telefono;
  final VoidCallback onTap;
  final bool recent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final iconSize = recent ? 30.0 : 32.0;

    return Material(
      color: recent ? colors.surfaceContainerHighest : colors.surface,
      borderRadius: recent ? BorderRadius.circular(10) : null,
      shape:
          recent
              ? null
              : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: colors.outlineVariant),
              ),
      child: ListTile(
        minVerticalPadding: recent ? 14 : 18,
        leading: Icon(
          recent ? Icons.history : Icons.person,
          size: iconSize,
        ),
        title: Text(
          direccion,
          style: text.titleLarge?.copyWith(
            fontWeight: recent ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
        subtitle: Text(telefono, style: text.titleMedium),
        trailing: Icon(Icons.chevron_right, size: iconSize),
        onTap: onTap,
      ),
    );
  }
}
