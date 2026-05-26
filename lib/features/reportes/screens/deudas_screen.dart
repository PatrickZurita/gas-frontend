import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/loading_card.dart';
import '../../../shared/message_box.dart';
import '../../../shared/summary_card.dart';
import '../../pedidos/models/pedido.dart';
import '../../pedidos/models/pedido_update_request.dart';
import '../../pedidos/pedido_service.dart';
import '../models/deudas_resumen.dart';
import '../models/pedido_reporte.dart';
import '../money_format.dart';
import '../services/reportes_service.dart';

class DeudasScreen extends StatefulWidget {
  const DeudasScreen({
    required this.reportesService,
    required this.pedidoService,
    this.onCambioPedido,
    super.key,
  });

  final ReportesService reportesService;
  final PedidoService pedidoService;
  final Future<void> Function()? onCambioPedido;

  @override
  State<DeudasScreen> createState() => _DeudasScreenState();
}

class _DeudasScreenState extends State<DeudasScreen> {
  late Future<DeudasResumen> _future;
  final Set<String> _processing = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = widget.reportesService.obtenerDeudas();
  }

  Future<void> _refresh() async {
    setState(_load);
    try {
      await _future;
    } catch (_) {
      // FutureBuilder muestra el error.
    }
  }

  Future<void> _marcarComoCobrado(PedidoReporte pedido) async {
    final metodo = await showDialog<MetodoPago>(
      context: context,
      builder: (_) => _ConfirmarCobroDialog(pedido: pedido),
    );
    if (metodo == null || !mounted) return;

    setState(() => _processing.add(pedido.id));
    try {
      await widget.pedidoService.editarPedido(
        pedido.id,
        PedidoUpdateRequest(
          pagado: true,
          montoPendienteCentavos: 0,
          metodoPago: metodo,
        ),
      );
      if (!mounted) return;
      await _refresh();
      await widget.onCambioPedido?.call();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${pedido.clienteAlias}: marcado como cobrado'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo marcar como cobrado.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _processing.remove(pedido.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deudas pendientes')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<DeudasResumen>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: LoadingCard(
                    message: 'Cargando deudas...',
                    icon: Icons.account_balance_wallet_outlined,
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
              final deudas = snapshot.data;
              if (deudas == null) return const SizedBox.shrink();
              return _Content(
                deudas: deudas,
                processing: _processing,
                onMarcarCobrado: _marcarComoCobrado,
              );
            },
          ),
        ),
      ),
    );
  }

  String _errorMessage(Object? error) {
    if (error is ApiException) return error.message;
    return 'No se pudieron cargar las deudas.';
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.deudas,
    required this.processing,
    required this.onMarcarCobrado,
  });

  final DeudasResumen deudas;
  final Set<String> processing;
  final void Function(PedidoReporte) onMarcarCobrado;

  @override
  Widget build(BuildContext context) {
    if (deudas.pedidos.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: const [
          MessageBox(message: 'Sin deudas pendientes.'),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        SummaryCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total por cobrar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                formatSolesFromCentavos(deudas.montoPendienteCentavos),
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${deudas.pedidosCount} pedido(s) por cobrar',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final pedido in deudas.pedidos)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _DeudaCard(
              pedido: pedido,
              procesando: processing.contains(pedido.id),
              onCobrado: () => onMarcarCobrado(pedido),
            ),
          ),
      ],
    );
  }
}

class _DeudaCard extends StatelessWidget {
  const _DeudaCard({
    required this.pedido,
    required this.procesando,
    required this.onCobrado,
  });

  final PedidoReporte pedido;
  final bool procesando;
  final VoidCallback onCobrado;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SummaryCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pedido.clienteAlias,
                      style: text.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pedido.cantidadBalones} balon(es) - ${_fechaCorta(pedido.fechaEntrega)}',
                      style: text.titleMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                formatSolesFromCentavos(pedido.montoPendienteCentavos),
                style: text.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: procesando ? null : onCobrado,
              icon: procesando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(procesando ? 'Guardando...' : 'Cobrado'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fechaCorta(DateTime date) {
    const meses = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    final dia = date.day.toString().padLeft(2, '0');
    return '$dia ${meses[date.month - 1]}';
  }
}

class _ConfirmarCobroDialog extends StatefulWidget {
  const _ConfirmarCobroDialog({required this.pedido});

  final PedidoReporte pedido;

  @override
  State<_ConfirmarCobroDialog> createState() => _ConfirmarCobroDialogState();
}

class _ConfirmarCobroDialogState extends State<_ConfirmarCobroDialog> {
  MetodoPago _metodo = MetodoPago.efectivo;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Marcar como cobrado'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.pedido.clienteAlias,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Pago ${formatSolesFromCentavos(widget.pedido.montoPendienteCentavos)}?',
            style: const TextStyle(fontSize: 17),
          ),
          const SizedBox(height: 14),
          const Text(
            'Como pago',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          SegmentedButton<MetodoPago>(
            segments: const [
              ButtonSegment<MetodoPago>(
                value: MetodoPago.efectivo,
                label: Text('Efectivo'),
                icon: Icon(Icons.payments_outlined),
              ),
              ButtonSegment<MetodoPago>(
                value: MetodoPago.yape,
                label: Text('Yape'),
                icon: Icon(Icons.phone_iphone),
              ),
            ],
            selected: {_metodo},
            onSelectionChanged: (selection) {
              setState(() {
                _metodo = selection.first;
              });
            },
            style: ButtonStyle(
              minimumSize: WidgetStateProperty.all(const Size.fromHeight(54)),
              textStyle:
                  WidgetStateProperty.all(const TextStyle(fontSize: 17)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_metodo),
          child: const Text('Si, cobrado'),
        ),
      ],
    );
  }
}

