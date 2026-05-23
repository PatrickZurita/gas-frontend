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

enum HistorialFiltro { todos, pagados, pendientes }

class HistorialFechaScreen extends StatefulWidget {
  const HistorialFechaScreen({
    required this.reportesService,
    this.pedidoService,
    this.onCambioPedido,
    super.key,
  });

  final ReportesService reportesService;
  final PedidoService? pedidoService;
  final Future<void> Function()? onCambioPedido;

  @override
  State<HistorialFechaScreen> createState() => _HistorialFechaScreenState();
}

class _HistorialFechaScreenState extends State<HistorialFechaScreen> {
  late DateTime _fecha;
  Future<ReporteDiario>? _reporteFuture;
  HistorialFiltro _filtro = HistorialFiltro.todos;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _fecha = DateTime(now.year, now.month, now.day);
    _load();
  }

  void _load() {
    _reporteFuture = widget.reportesService.obtenerReporteDia(_fecha);
  }

  void _cambiarFecha(DateTime fecha) {
    setState(() {
      _fecha = DateTime(fecha.year, fecha.month, fecha.day);
      _load();
    });
  }

  Future<void> _refresh() async {
    setState(_load);
    try {
      await _reporteFuture;
    } catch (_) {
      // FutureBuilder renders the latest error state.
    }
  }

  Future<void> _elegirFecha() async {
    final ahora = DateTime.now();
    final inicio = DateTime(ahora.year - 1, ahora.month, ahora.day);
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: inicio,
      lastDate: ahora,
      helpText: 'Elegir fecha',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (elegida != null) {
      _cambiarFecha(elegida);
    }
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
      await _refresh();
    }
  }

  bool _esMismaFecha(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hoy = DateTime(now.year, now.month, now.day);
    final ayer = hoy.subtract(const Duration(days: 1));
    final esHoy = _esMismaFecha(_fecha, hoy);
    final esAyer = _esMismaFecha(_fecha, ayer);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial por fecha')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _FechaButton(
                      label: 'Hoy',
                      selected: esHoy,
                      onPressed: () => _cambiarFecha(hoy),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _FechaButton(
                      label: 'Ayer',
                      selected: esAyer,
                      onPressed: () => _cambiarFecha(ayer),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _FechaButton(
                      label: 'Elegir fecha',
                      icon: Icons.calendar_month_outlined,
                      selected: !esHoy && !esAyer,
                      onPressed: _elegirFecha,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                _formatDateLong(_fecha),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: FutureBuilder<ReporteDiario>(
                  future: _reporteFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: LoadingCard(
                          message: 'Cargando pedidos...',
                          icon: Icons.calendar_today_outlined,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        children: [
                          MessageBox(
                            message: _errorMessage(snapshot.error),
                            type: MessageBoxType.error,
                          ),
                        ],
                      );
                    }

                    final reporte = snapshot.data;
                    if (reporte == null) {
                      return const SizedBox.shrink();
                    }

                    return _HistorialContent(
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
            ),
          ],
        ),
      ),
    );
  }

  String _errorMessage(Object? error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'No se pudo cargar el dia.';
  }

  String _formatDateLong(DateTime date) {
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

  String _capitalize(String value) =>
      '${value[0].toUpperCase()}${value.substring(1)}';
}

class _FechaButton extends StatelessWidget {
  const _FechaButton({
    required this.label,
    required this.selected,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon ?? Icons.check, size: 22),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.calendar_today_outlined, size: 22),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}

class _HistorialContent extends StatelessWidget {
  const _HistorialContent({
    required this.reporte,
    required this.filtro,
    required this.onFiltroChanged,
    this.onPedidoTap,
  });

  final ReporteDiario reporte;
  final HistorialFiltro filtro;
  final ValueChanged<HistorialFiltro> onFiltroChanged;
  final void Function(PedidoReporte)? onPedidoTap;

  @override
  Widget build(BuildContext context) {
    final pedidos = _filtrar(reporte.pedidos, filtro);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        SummaryCard(
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
        ),
        const SizedBox(height: 16),
        SegmentedButton<HistorialFiltro>(
          segments: const [
            ButtonSegment(value: HistorialFiltro.todos, label: Text('Todos')),
            ButtonSegment(
              value: HistorialFiltro.pagados,
              label: Text('Pagados'),
            ),
            ButtonSegment(
              value: HistorialFiltro.pendientes,
              label: Text('Pendientes'),
            ),
          ],
          selected: {filtro},
          onSelectionChanged: (selection) => onFiltroChanged(selection.first),
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(const Size.fromHeight(56)),
          ),
        ),
        const SizedBox(height: 16),
        if (reporte.isEmpty)
          const MessageBox(message: 'No hay pedidos para esta fecha.')
        else if (pedidos.isEmpty)
          const MessageBox(message: 'No hay pedidos con este filtro.')
        else
          SummaryCard(
            padding: EdgeInsets.zero,
            borderRadius: 8,
            child: Column(
              children: [
                for (var i = 0; i < pedidos.length; i++)
                  _HistorialRow(
                    pedido: pedidos[i],
                    showDivider: i < pedidos.length - 1,
                    onTap: onPedidoTap == null
                        ? null
                        : () => onPedidoTap!(pedidos[i]),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  List<PedidoReporte> _filtrar(
    List<PedidoReporte> pedidos,
    HistorialFiltro filtro,
  ) {
    switch (filtro) {
      case HistorialFiltro.todos:
        return pedidos;
      case HistorialFiltro.pagados:
        return pedidos.where((p) => p.pagado).toList();
      case HistorialFiltro.pendientes:
        return pedidos.where((p) => !p.pagado).toList();
    }
  }
}

class _HistorialRow extends StatelessWidget {
  const _HistorialRow({
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
          '${pedido.cantidadBalones == 1 ? '1 balon' : '${pedido.cantidadBalones} balones'} ${pedido.pesoBalonKg} kg',
          style: const TextStyle(fontSize: 17),
        ),
        if (pedido.esAnulado)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
}
