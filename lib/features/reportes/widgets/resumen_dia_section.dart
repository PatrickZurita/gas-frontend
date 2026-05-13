import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/loading_card.dart';
import '../../../shared/message_box.dart';
import '../../../shared/metric_card.dart';
import '../../../shared/summary_card.dart';
import '../models/reporte_diario.dart';
import '../money_format.dart';
import '../screens/pedidos_dia_screen.dart';
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
          return const LoadingCard(
            message: 'Cargando resumen...',
            icon: Icons.insights_outlined,
          );
        }

        if (snapshot.hasError) {
          return SummaryCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Resumen del dia',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                MessageBox(
                  message: _errorMessage(snapshot.error),
                  type: MessageBoxType.error,
                ),
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

        return SummaryCard(
          child: _ResumenContent(
            resumen: resumen,
            reportesService: widget.reportesService,
          ),
        );
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
  const _ResumenContent({required this.resumen, required this.reportesService});

  final ReporteDiario resumen;
  final ReportesService reportesService;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _openPedidosDia(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Resumen del dia',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.primary,
                size: 30,
              ),
            ],
          ),
          const SizedBox(height: 12),
          MetricCard(
            label: 'Total vendido',
            value: formatSolesFromCentavos(resumen.montoTotalCentavos),
            primary: true,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  label: 'Pagado',
                  value: formatSolesFromCentavos(resumen.montoPagadoCentavos),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricCard(
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
                child: MetricCard(
                  label: 'Pedidos',
                  value: '${resumen.pedidosCount}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricCard(
                  label: 'Balones',
                  value: '${resumen.balonesVendidos}',
                ),
              ),
            ],
          ),
          if (resumen.isEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Aun no hay pedidos hoy.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ] else ...[
            const SizedBox(height: 12),
            Text(
              '${resumen.pedidosCount} pedidos registrados hoy. Toca para verlos.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openPedidosDia(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => PedidosDiaScreen(
              reportesService: reportesService,
              initialReporte: resumen,
            ),
      ),
    );
  }
}

