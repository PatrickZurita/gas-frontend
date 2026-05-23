import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/compact_list_item.dart';
import '../../../shared/loading_card.dart';
import '../../../shared/message_box.dart';
import '../../../shared/metric_line.dart';
import '../../../shared/status_badge.dart';
import '../../../shared/summary_card.dart';
import '../../pedidos/pedido_service.dart';
import '../../pedidos/screens/detalle_pedido_screen.dart';
import '../models/pedido_reporte.dart';
import '../models/reporte_diario.dart';
import '../money_format.dart';
import '../services/reportes_service.dart';

enum PedidoDiaFiltro { todos, pagados, pendientes }

class PedidosDiaScreen extends StatefulWidget {
  const PedidosDiaScreen({
    required this.reportesService,
    this.pedidoService,
    this.initialReporte,
    this.fecha,
    this.onCambioPedido,
    super.key,
  });

  final ReportesService reportesService;
  final PedidoService? pedidoService;
  final ReporteDiario? initialReporte;

  /// Si se provee, abre el reporte de esa fecha en vez del resumen de hoy.
  /// Se ignora si `initialReporte` ya viene precargado.
  final DateTime? fecha;
  final Future<void> Function()? onCambioPedido;

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
    if (initial != null) {
      _reporteFuture = Future<ReporteDiario>.value(initial);
    } else if (widget.fecha != null) {
      _reporteFuture = widget.reportesService.obtenerReporteDia(widget.fecha!);
    } else {
      _reporteFuture = widget.reportesService.obtenerResumenHoy();
    }
  }

  Future<void> _retry() async {
    setState(() {
      _reporteFuture = widget.fecha != null
          ? widget.reportesService.obtenerReporteDia(widget.fecha!)
          : widget.reportesService.obtenerResumenHoy();
    });
  }

  Future<void> _abrirDetalle(PedidoReporte pedido) async {
    final pedidoService = widget.pedidoService;
    if (pedidoService == null) return;

    final cambio = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => DetallePedidoScreen(
          pedido: pedido.toPedidoDetalle(),
          pedidoService: pedidoService,
          clienteAlias: pedido.clienteAlias,
          onCambioPedido: widget.onCambioPedido,
        ),
      ),
    );

    if (cambio == true && mounted) {
      await _retry();
    }
  }

  String _tituloAppBar() {
    final fecha = widget.fecha;
    if (fecha == null) return 'Pedidos de hoy';
    final hoy = DateTime.now();
    final esHoy = fecha.year == hoy.year &&
        fecha.month == hoy.month &&
        fecha.day == hoy.day;
    if (esHoy) return 'Pedidos de hoy';
    const meses = [
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
    return 'Pedidos ${fecha.day} ${meses[fecha.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_tituloAppBar())),
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
              onPedidoTap:
                  widget.pedidoService == null ? null : _abrirDetalle,
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
    this.onPedidoTap,
  });

  final ReporteDiario reporte;
  final PedidoDiaFiltro filtro;
  final ValueChanged<PedidoDiaFiltro> onFiltroChanged;
  final void Function(PedidoReporte)? onPedidoTap;

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
          _PedidosDiaList(pedidos: pedidos, onPedidoTap: onPedidoTap),
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
  const _PedidosDiaList({required this.pedidos, this.onPedidoTap});

  final List<PedidoReporte> pedidos;
  final void Function(PedidoReporte)? onPedidoTap;

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
              onTap: onPedidoTap == null
                  ? null
                  : () => onPedidoTap!(pedidos[index]),
            ),
        ],
      ),
    );
  }
}

class _PedidoDiaRow extends StatelessWidget {
  const _PedidoDiaRow({
    required this.pedido,
    required this.showDivider,
    this.onTap,
  });

  final PedidoReporte pedido;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final row = CompactListItem(
      title: pedido.clienteAlias,
      trailing: formatSolesFromCentavos(pedido.montoTotalCentavos),
      showDivider: showDivider,
      details: [
        Text(
          '${_balonesText(pedido.cantidadBalones)} ${pedido.pesoBalonKg} kg',
          style: const TextStyle(fontSize: 17),
        ),
        Text(
          '${_displayCode(pedido.marcaBalon)} / ${_displayCode(pedido.tipoBalon)}',
          style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant),
        ),
        if (pedido.esAnulado)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: colors.outline, width: 0.8),
            ),
            child: Text(
              'ANULADO',
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          )
        else
          StatusBadge(
            label: pedido.pagado ? 'Pagado' : 'Debe',
            type: pedido.pagado ? StatusBadgeType.paid : StatusBadgeType.debt,
          ),
      ],
    );

    if (onTap == null) {
      return row;
    }

    return InkWell(onTap: onTap, child: row);
  }

  String _balonesText(int cantidad) {
    return cantidad == 1 ? '1 balon' : '$cantidad balones';
  }

  String _displayCode(String value) {
    if (value.isEmpty) return value;
    final lower = value.toLowerCase();
    return '${lower[0].toUpperCase()}${lower.substring(1)}';
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

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
