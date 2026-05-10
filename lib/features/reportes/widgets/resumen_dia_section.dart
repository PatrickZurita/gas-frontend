import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../models/reporte_diario.dart';
import '../money_format.dart';
import '../services/reportes_service.dart';

class ResumenDiaSection extends StatefulWidget {
  const ResumenDiaSection({required this.reportesService, super.key});

  final ReportesService reportesService;

  @override
  State<ResumenDiaSection> createState() => _ResumenDiaSectionState();
}

class _ResumenDiaSectionState extends State<ResumenDiaSection> {
  late Future<ReporteDiario> _resumenFuture;

  @override
  void initState() {
    super.initState();
    _loadResumen();
  }

  void _loadResumen() {
    _resumenFuture = widget.reportesService.obtenerResumenHoy();
  }

  void _retry() {
    setState(_loadResumen);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ReporteDiario>(
      future: _resumenFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _ResumenFrame(
            child: Column(
              children: [
                SizedBox(height: 8),
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Cargando resumen...', style: TextStyle(fontSize: 18)),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return _ResumenFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Resumen del dia',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(_errorMessage(snapshot.error)),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final resumen = snapshot.data;
        if (resumen == null) {
          return const SizedBox.shrink();
        }

        return _ResumenContent(resumen: resumen);
      },
    );
  }

  String _errorMessage(Object? error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'No se pudo cargar el resumen.';
  }
}

class _ResumenContent extends StatelessWidget {
  const _ResumenContent({required this.resumen});

  final ReporteDiario resumen;

  @override
  Widget build(BuildContext context) {
    return _ResumenFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen del dia',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          _MetricBlock(
            label: 'Total vendido',
            value: formatSolesFromCentavos(resumen.montoTotalCentavos),
            primary: true,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetricBlock(
                  label: 'Pagado',
                  value: formatSolesFromCentavos(resumen.montoPagadoCentavos),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricBlock(
                  label: 'Pendiente',
                  value: formatSolesFromCentavos(
                    resumen.montoPendienteCentavos,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetricBlock(
                  label: 'Pedidos',
                  value: '${resumen.pedidosCount}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricBlock(
                  label: 'Balones',
                  value: '${resumen.balonesVendidos}',
                ),
              ),
            ],
          ),
          if (resumen.isEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Aun no hay pedidos hoy.',
              style: TextStyle(fontSize: 18),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Text(
              '${resumen.pedidosCount} pedidos registrados hoy.',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResumenFrame extends StatelessWidget {
  const _ResumenFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: child,
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({
    required this.label,
    required this.value,
    this.primary = false,
  });

  final String label;
  final String value;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
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
            style: TextStyle(
              fontSize: primary ? 18 : 15,
              fontWeight: primary ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: primary ? 38 : 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
