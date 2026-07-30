import 'package:flutter/material.dart';

import '../../../shared/peso_balon_selector.dart';
import '../../../shared/quantity_button.dart';
import '../models/demanda_perdida_create_request.dart';

/// Abre el bottom sheet de "No atendido" (P1 #2, dos toques cero tipeo).
/// Devuelve el request listo para enviar, o null si el operador cancelo.
/// Elegir el motivo cierra el sheet de inmediato; los opcionales solo se
/// incluyen si el operador los toco.
Future<DemandaPerdidaCreateRequest?> showDemandaPerdidaSheet(
  BuildContext context,
) {
  return showModalBottomSheet<DemandaPerdidaCreateRequest>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const DemandaPerdidaSheet(),
  );
}

class DemandaPerdidaSheet extends StatefulWidget {
  const DemandaPerdidaSheet({super.key});

  @override
  State<DemandaPerdidaSheet> createState() => _DemandaPerdidaSheetState();
}

class _DemandaPerdidaSheetState extends State<DemandaPerdidaSheet> {
  static const int _minCantidad = 1;
  static const int _maxCantidad = 20;

  final TextEditingController _zonaController = TextEditingController();
  int _cantidad = _minCantidad;
  int _pesoBalonKg = 10;

  @override
  void dispose() {
    _zonaController.dispose();
    super.dispose();
  }

  void _elegirMotivo(String motivo) {
    final zona = _zonaController.text.trim();
    Navigator.of(context).pop(
      DemandaPerdidaCreateRequest(
        motivo: motivo,
        cantidadBalones: _cantidad == _minCantidad ? null : _cantidad,
        pesoBalonKg: _pesoBalonKg == 10 ? null : _pesoBalonKg,
        zonaTexto: zona.isEmpty ? null : zona,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Llamada no atendida',
              style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Toca el motivo y se guarda al instante.',
              style: text.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MotivoButton(
                    label: 'Sin stock',
                    icon: Icons.inventory_2_outlined,
                    onPressed:
                        () => _elegirMotivo(DemandaPerdidaMotivo.sinStock),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MotivoButton(
                    label: 'Fuera de zona',
                    icon: Icons.location_off_outlined,
                    onPressed:
                        () => _elegirMotivo(DemandaPerdidaMotivo.fueraDeZona),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MotivoButton(
                    label: 'Saturado',
                    icon: Icons.local_shipping_outlined,
                    onPressed:
                        () => _elegirMotivo(DemandaPerdidaMotivo.saturado),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MotivoButton(
                    label: 'Otro',
                    icon: Icons.help_outline,
                    onPressed: () => _elegirMotivo(DemandaPerdidaMotivo.otro),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Detalle opcional (puedes ignorarlo)',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            PesoBalonSelector(
              value: _pesoBalonKg,
              onChanged: (value) {
                setState(() {
                  _pesoBalonKg = value;
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Balones pedidos',
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                QuantityButton(
                  icon: Icons.remove,
                  size: 56,
                  onPressed:
                      _cantidad > _minCantidad
                          ? () => setState(() => _cantidad--)
                          : null,
                ),
                SizedBox(
                  width: 56,
                  child: Text(
                    '$_cantidad',
                    textAlign: TextAlign.center,
                    style: text.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                QuantityButton(
                  icon: Icons.add,
                  size: 56,
                  onPressed:
                      _cantidad < _maxCantidad
                          ? () => setState(() => _cantidad++)
                          : null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _zonaController,
              textInputAction: TextInputAction.done,
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(
                labelText: 'Zona (opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.place_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MotivoButton extends StatelessWidget {
  const _MotivoButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 26),
      label: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(68),
        padding: const EdgeInsets.symmetric(horizontal: 10),
      ),
    );
  }
}
