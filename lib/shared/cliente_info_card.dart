import 'package:flutter/material.dart';

import 'summary_card.dart';

class ClienteInfoCard extends StatelessWidget {
  const ClienteInfoCard({
    required this.direccion,
    required this.telefono,
    super.key,
  });

  final String direccion;
  final String telefono;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SummaryCard(
      borderRadius: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cliente', style: text.labelLarge),
          const SizedBox(height: 4),
          Text(
            direccion,
            style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(telefono, style: text.titleMedium),
        ],
      ),
    );
  }
}
