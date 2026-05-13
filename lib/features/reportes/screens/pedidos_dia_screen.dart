import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
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
              return const Center(child: CircularProgressIndicator());
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
          const _MessageBox(message: 'No hay pedidos con este filtro.')
        else
          ...pedidos.map(
            (pedido) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PedidoDiaCard(pedido: pedido),
            ),
          ),
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
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _TotalsFrame extends StatelessWidget {
  const _TotalsFrame({required this.reporte});

  final ReporteDiario reporte;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TotalLine(
            label: 'Total vendido',
            value: formatSolesFromCentavos(reporte.montoTotalCentavos),
            strong: true,
          ),
          _TotalLine(
            label: 'Pagado',
            value: formatSolesFromCentavos(reporte.montoPagadoCentavos),
          ),
          _TotalLine(
            label: 'Pendiente',
            value: formatSolesFromCentavos(reporte.montoPendienteCentavos),
          ),
          _TotalLine(label: 'Pedidos', value: '${reporte.pedidosCount}'),
          _TotalLine(label: 'Balones', value: '${reporte.balonesVendidos}'),
        ],
      ),
    );
  }
}

class _TotalLine extends StatelessWidget {
  const _TotalLine({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 18))),
          Text(
            value,
            style: TextStyle(
              fontSize: strong ? 24 : 20,
              fontWeight: FontWeight.w800,
            ),
          ),
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
        textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _PedidoDiaCard extends StatelessWidget {
  const _PedidoDiaCard({required this.pedido});

  final PedidoReporte pedido;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pedido.clienteAlias,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          _InfoLine(label: 'Balones', value: '${pedido.cantidadBalones}'),
          _InfoLine(label: 'Marca', value: _displayCode(pedido.marcaBalon)),
          _InfoLine(label: 'Tipo', value: _displayCode(pedido.tipoBalon)),
          _InfoLine(
            label: 'Monto',
            value: formatSolesFromCentavos(pedido.montoTotalCentavos),
          ),
          _InfoLine(
            label: 'Estado',
            value: pedido.pagado ? 'Pagado' : 'Pendiente',
          ),
        ],
      ),
    );
  }

  String _displayCode(String value) {
    final lower = value.toLowerCase();
    return '${lower[0].toUpperCase()}${lower.substring(1)}';
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 17))),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
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
          _MessageBox(message: message),
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

class _MessageBox extends StatelessWidget {
  const _MessageBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message, style: const TextStyle(fontSize: 18)),
    );
  }
}
