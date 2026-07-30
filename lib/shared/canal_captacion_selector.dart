import 'package:flutter/material.dart';

class CanalCaptacionOpcion {
  const CanalCaptacionOpcion(this.codigo, this.nombre);

  final String codigo;
  final String nombre;
}

/// Selector de un toque del canal de captacion (P1 #1). Opcional y
/// skippeable: sin seleccion el valor queda en null y no se envia.
/// Tocar el chip ya elegido lo deselecciona.
class CanalCaptacionSelector extends StatelessWidget {
  const CanalCaptacionSelector({
    required this.value,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  static const List<CanalCaptacionOpcion> opciones = [
    CanalCaptacionOpcion('VOLANTE', 'Volante'),
    CanalCaptacionOpcion('FACEBOOK', 'Facebook'),
    CanalCaptacionOpcion('RECOMENDACION', 'Recomendacion'),
    CanalCaptacionOpcion('CARTEL', 'Cartel'),
    CanalCaptacionOpcion('ANTIGUO', 'Antiguo'),
    CanalCaptacionOpcion('OTRO', 'Otro'),
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Como nos conocio (opcional)',
          style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              opciones
                  .map(
                    (opcion) => ChoiceChip(
                      label: Text(opcion.nombre),
                      labelStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      labelPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      selected: value == opcion.codigo,
                      onSelected:
                          enabled
                              ? (selected) =>
                                  onChanged(selected ? opcion.codigo : null)
                              : null,
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}
