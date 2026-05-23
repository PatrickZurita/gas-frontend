import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/data_chip.dart';
import '../../../shared/loading_card.dart';
import '../../../shared/message_box.dart';
import '../../../shared/metric_card.dart';
import '../../../shared/summary_card.dart';
import '../../pedidos/pedido_service.dart';
import '../models/reporte_dia_breve.dart';
import '../models/reporte_mensual.dart';
import '../money_format.dart';
import '../services/reportes_service.dart';
import 'pedidos_dia_screen.dart';
import 'reporte_tablet_layouts.dart';

class ReporteMensualScreen extends StatefulWidget {
  const ReporteMensualScreen({
    required this.reportesService,
    this.pedidoService,
    this.onCambioPedido,
    super.key,
  });

  final ReportesService reportesService;
  final PedidoService? pedidoService;
  final Future<void> Function()? onCambioPedido;

  @override
  State<ReporteMensualScreen> createState() => _ReporteMensualScreenState();
}

class _ReporteMensualScreenState extends State<ReporteMensualScreen> {
  late DateTime _mes;
  Future<ReporteMensual>? _future;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _mes = DateTime(now.year, now.month);
    _load();
  }

  void _load() {
    _future = widget.reportesService.obtenerReporteMes(_mes);
  }

  Future<void> _refresh() async {
    setState(_load);
    try {
      await _future;
    } catch (_) {
      // FutureBuilder handles error rendering.
    }
  }

  void _moverMes(int delta) {
    setState(() {
      _mes = DateTime(_mes.year, _mes.month + delta);
      _load();
    });
  }

  Future<void> _abrirDia(DateTime fecha) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PedidosDiaScreen(
          reportesService: widget.reportesService,
          pedidoService: widget.pedidoService,
          fecha: fecha,
          onCambioPedido: widget.onCambioPedido,
        ),
      ),
    );
    if (!mounted) return;
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reporte mensual')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 720;
            return RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<ReporteMensual>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: LoadingCard(
                        message: 'Cargando reporte mensual...',
                        icon: Icons.calendar_month_outlined,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      children: [
                        MessageBox(message: _errorMessage(snapshot.error)),
                      ],
                    );
                  }

                  final reporte = snapshot.data;
                  if (reporte == null) {
                    return const SizedBox.shrink();
                  }

                  if (isTablet) {
                    return TabletMensualLayout(
                      reporte: reporte,
                      header: _Header(
                        mes: _mes,
                        onPrev: () => _moverMes(-1),
                        onNext: () => _moverMes(1),
                      ),
                      onAbrirDia: _abrirDia,
                    );
                  }

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    children: [
                      _Header(
                        mes: _mes,
                        onPrev: () => _moverMes(-1),
                        onNext: () => _moverMes(1),
                      ),
                      const SizedBox(height: 12),
                      _ResumenMensualMobile(reporte: reporte),
                      const SizedBox(height: 16),
                      _DiasList(
                        dias: reporte.dias,
                        onAbrirDia: _abrirDia,
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  String _errorMessage(Object? error) {
    if (error is ApiException) return error.message;
    return 'No se pudo cargar el reporte.';
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.mes,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime mes;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: onPrev,
          icon: const Icon(Icons.chevron_left, size: 28),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mes',
                style: text.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _mesLargo(mes),
                style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right, size: 28),
        ),
      ],
    );
  }

  String _mesLargo(DateTime date) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _ResumenMensualMobile extends StatelessWidget {
  const _ResumenMensualMobile({required this.reporte});

  final ReporteMensual reporte;

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MetricCard(
            label: 'Total vendido',
            value: formatSolesFromCentavos(reporte.montoTotalCentavos),
            primary: true,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  label: 'Cobrado',
                  value: formatSolesFromCentavos(reporte.montoCobradoCentavos),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricCard(
                  label: 'Pendiente',
                  value:
                      formatSolesFromCentavos(reporte.montoPendienteCentavos),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  label: 'Balones 10 kg',
                  value: '${reporte.balonesVendidos10kg}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricCard(
                  label: 'Balones 45 kg',
                  value: '${reporte.balonesVendidos45kg}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DataChip(label: 'Pedidos', value: '${reporte.pedidosCount}'),
              DataChip(label: 'Balones', value: '${reporte.balonesVendidos}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _DiasList extends StatelessWidget {
  const _DiasList({required this.dias, this.onAbrirDia});

  final List<ReporteDiaBreve> dias;
  final void Function(DateTime fecha)? onAbrirDia;

  @override
  Widget build(BuildContext context) {
    if (dias.isEmpty) {
      return const MessageBox(message: 'Sin ventas en este mes.');
    }
    return SummaryCard(
      padding: EdgeInsets.zero,
      borderRadius: 8,
      child: Column(
        children: [
          for (var i = 0; i < dias.length; i++) ...[
            DiaBreveTile(
              dia: dias[i],
              onTap: onAbrirDia == null || dias[i].pedidosCount == 0
                  ? null
                  : () => onAbrirDia!(dias[i].fecha),
            ),
            if (i < dias.length - 1)
              Divider(
                height: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
          ],
        ],
      ),
    );
  }
}
