import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/compact_list_item.dart';
import '../../../shared/loading_card.dart';
import '../../../shared/message_box.dart';
import '../../../shared/metric_line.dart';
import '../../../shared/status_badge.dart';
import '../../../shared/summary_card.dart';
import '../models/pedido_reporte.dart';
import '../models/reporte_diario.dart';
import '../money_format.dart';
import '../services/reportes_service.dart';

enum PedidoDiaFiltro { todos, pagados, pendientes }

class PedidosDiaScreen extends StatefulWidget {
  const PedidosDiaScreen({
    required this.reportesService,
    this.initialReporte,
    super.key,
  });

  final ReportesService reportesService;
  final ReporteDiario? initialReporte;

  @override
  State<PedidosDiaScreen> createState() => _PedidosDiaScreenState();
}

class _PedidosDiaScreenState extends State<PedidosDiaScreen> {
  late Future<ReporteDiario> _reporteFuture;
  PedidoDiaFiltro _filtro = PedidoDiaFiltro.todos;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialReporte;
    _reporteFuture =
        initial == null
            ? widget.reportesService.obtenerResumenHoy()
            : Future<ReporteDiario>.value(initial);
  }

  void _retry() {
    setState(() {
      _reporteFuture = widget.reportesService.obtenerResumenHoy();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos de hoy')),
      body: SafeArea(
        child: FutureBuilder<ReporteDiario>(
          future: _reporteFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: LoadingCard(
                  message: 'Cargando pedidos de hoy...',
                  icon: Icons.receipt_long_outlined,
                ),
              );
            }

            if (snapshot.hasError) {
              return _ErrorState(
                message: _errorMessage(snapshot.error),
                onRetry: _retry,
              );
            }

            final reporte = snapshot.data;
            if (reporte == null) {
              return const SizedBox.shrink();
            }

            return _PedidosDiaContent(
              reporte: reporte,
              filtro: _filtro,
              onFiltroChanged: (value) {
                setState(() {
                  _filtro = value;
                });
              },
            );
          },
        ),
      ),
    );
  }

  String _errorMessage(Object? error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'No se pudo cargar los pedidos.';
  }
}

class _PedidosDiaContent extends StatelessWidget {
  const _PedidosDiaContent({
    required this.reporte,
    required this.filtro,
    required this.onFiltroChanged,
  });

  final ReporteDiario reporte;
  final PedidoDiaFiltro filtro;
  final ValueChanged<PedidoDiaFiltro> onFiltroChanged;

  @override
  Widget build(BuildContext context) {
    final pedidos = _filtrarPedidos(reporte.pedidos, filtro);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Pedidos de hoy',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(_formatDate(reporte.fecha), style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 16),
        _TotalsFrame(reporte: reporte),
        const SizedBox(height: 16),
        _FiltroPedidos(selected: filtro, onChanged: onFiltroChanged),
        const SizedBox(height: 16),
        if (pedidos.isEmpty)
          const MessageBox(message: 'No hay pedidos con este filtro.')
        else
          _PedidosDiaList(pedidos: pedidos),
      ],
    );
  }

  List<PedidoReporte> _filtrarPedidos(
    List<PedidoReporte> pedidos,
    PedidoDiaFiltro filtro,
  ) {
    switch (filtro) {
      case PedidoDiaFiltro.todos:
        return pedidos;
      case PedidoDiaFiltro.pagados:
        return pedidos.where((pedido) => pedido.pagado).toList();
      case PedidoDiaFiltro.pendientes:
        return pedidos.where((pedido) => !pedido.pagado).toList();
    }
  }

  String _formatDate(DateTime date) {
    const weekdays = [
      'lunes',
      'martes',
      'miercoles',
      'jueves',
      'viernes',
      'sabado',
      'domingo',
    ];
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    return '${_capitalize(weekday)} ${date.day} de $month de ${date.year}';
  }

  String _capitalize(String value) {
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}

class _TotalsFrame extends StatelessWidget {
  const _TotalsFrame({required this.reporte});

  final ReporteDiario reporte;

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      borderRadius: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MetricLine(
            label: 'Total vendido',
            value: formatSolesFromCentavos(reporte.montoTotalCentavos),
            strong: true,
          ),
          MetricLine(
            label: 'Pagado',
            value: formatSolesFromCentavos(reporte.montoPagadoCentavos),
          ),
          MetricLine(
            label: 'Pendiente',
            value: formatSolesFromCentavos(reporte.montoPendienteCentavos),
          ),
          MetricLine(label: 'Pedidos', value: '${reporte.pedidosCount}'),
          MetricLine(label: 'Balones', value: '${reporte.balonesVendidos}'),
        ],
      ),
    );
  }
}

class _FiltroPedidos extends StatelessWidget {
  const _FiltroPedidos({required this.selected, required this.onChanged});

  final PedidoDiaFiltro selected;
  final ValueChanged<PedidoDiaFiltro> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<PedidoDiaFiltro>(
      segments: const [
        ButtonSegment<PedidoDiaFiltro>(
          value: PedidoDiaFiltro.todos,
          label: Text('Todos'),
        ),
        ButtonSegment<PedidoDiaFiltro>(
          value: PedidoDiaFiltro.pagados,
          label: Text('Pagados'),
        ),
        ButtonSegment<PedidoDiaFiltro>(
          value: PedidoDiaFiltro.pendientes,
          label: Text('Pendientes'),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (selection) => onChanged(selection.first),
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size.fromHeight(56)),
        textStyle: WidgetStateProperty.all(
          Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

class _PedidosDiaList extends StatelessWidget {
  const _PedidosDiaList({required this.pedidos});

  final List<PedidoReporte> pedidos;

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      padding: EdgeInsets.zero,
      borderRadius: 8,
      child: Column(
        children: [
          for (var index = 0; index < pedidos.length; index++)
            _PedidoDiaRow(
              pedido: pedidos[index],
              showDivider: index < pedidos.length - 1,
            ),
        ],
      ),
    );
  }
}

class _PedidoDiaRow extends StatelessWidget {
  const _PedidoDiaRow({required this.pedido, required this.showDivider});

  final PedidoReporte pedido;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return CompactListItem(
      title: pedido.clienteAlias,
      trailing: formatSolesFromCentavos(pedido.montoTotalCentavos),
      showDivider: showDivider,
      details: [
        Text(
          _balonesText(pedido.cantidadBalones),
          style: const TextStyle(fontSize: 17),
        ),
        Text(
          '${_displayCode(pedido.marcaBalon)} / ${_displayCode(pedido.tipoBalon)}',
          style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant),
        ),
        StatusBadge(
          label: pedido.pagado ? 'Pagado' : 'Debe',
          type: pedido.pagado ? StatusBadgeType.paid : StatusBadgeType.debt,
        ),
      ],
    );
  }

  String _balonesText(int cantidad) {
    return cantidad == 1 ? '1 balon' : '$cantidad balones';
  }

  String _displayCode(String value) {
    final lower = value.toLowerCase();
    return '${lower[0].toUpperCase()}${lower.substring(1)}';
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Pedidos de hoy',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          MessageBox(message: message),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
