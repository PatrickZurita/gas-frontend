import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/loading_card.dart';
import '../../../shared/message_box.dart';
import '../../../shared/summary_card.dart';
import '../../pedidos/pedido_service.dart';
import '../models/deudas_resumen.dart';
import '../money_format.dart';
import '../screens/deudas_screen.dart';
import '../services/reportes_service.dart';

class DeudasPendientesSection extends StatefulWidget {
  const DeudasPendientesSection({
    required this.reportesService,
    this.pedidoService,
    this.onCambioPedido,
    super.key,
  });

  final ReportesService reportesService;
  final PedidoService? pedidoService;
  final Future<void> Function()? onCambioPedido;

  @override
  State<DeudasPendientesSection> createState() =>
      DeudasPendientesSectionState();
}

class DeudasPendientesSectionState extends State<DeudasPendientesSection> {
  late Future<DeudasResumen> _deudasFuture;

  @override
  void initState() {
    super.initState();
    _loadDeudas();
  }

  void _loadDeudas() {
    _deudasFuture = widget.reportesService.obtenerDeudas();
  }

  void _retry() {
    setState(_loadDeudas);
  }

  Future<void> refresh() async {
    late final Future<DeudasResumen> nextFuture;
    setState(() {
      nextFuture = widget.reportesService.obtenerDeudas();
      _deudasFuture = nextFuture;
    });
    try {
      await nextFuture;
    } catch (_) {
      // FutureBuilder renders the latest error state.
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DeudasResumen>(
      future: _deudasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingCard(
            message: 'Cargando deudas...',
            icon: Icons.account_balance_wallet_outlined,
          );
        }

        if (snapshot.hasError) {
          return SummaryCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Deudas pendientes',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
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

        final deudas = snapshot.data;
        if (deudas == null) {
          return const SizedBox.shrink();
        }

        return _DeudasContent(
          deudas: deudas,
          reportesService: widget.reportesService,
          pedidoService: widget.pedidoService,
          onCambioPedido: () async {
            await refresh();
            await widget.onCambioPedido?.call();
          },
        );
      },
    );
  }

  String _errorMessage(Object? error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'No se pudo cargar las deudas.';
  }
}

class _DeudasContent extends StatelessWidget {
  const _DeudasContent({
    required this.deudas,
    required this.reportesService,
    this.pedidoService,
    this.onCambioPedido,
  });

  final DeudasResumen deudas;
  final ReportesService reportesService;
  final PedidoService? pedidoService;
  final Future<void> Function()? onCambioPedido;

  @override
  Widget build(BuildContext context) {
    final puedeAbrir = deudas.pedidos.isNotEmpty && pedidoService != null;
    return SummaryCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Deudas',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  deudas.pedidos.isEmpty
                      ? 'Sin deudas pendientes'
                      : '${deudas.pedidosCount} pedidos por cobrar',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formatSolesFromCentavos(deudas.montoPendienteCentavos),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: puedeAbrir ? () => _abrirDeudas(context) : null,
            child: const Text('Ver'),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirDeudas(BuildContext context) async {
    final service = pedidoService;
    if (service == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => DeudasScreen(
          reportesService: reportesService,
          pedidoService: service,
          onCambioPedido: onCambioPedido,
        ),
      ),
    );
  }
}

