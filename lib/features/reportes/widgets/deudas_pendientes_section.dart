import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/loading_card.dart';
import '../../../shared/message_box.dart';
import '../../../shared/summary_card.dart';
import '../models/deudas_resumen.dart';
import '../money_format.dart';
import '../services/reportes_service.dart';

class DeudasPendientesSection extends StatefulWidget {
  const DeudasPendientesSection({required this.reportesService, super.key});

  final ReportesService reportesService;

  @override
  State<DeudasPendientesSection> createState() =>
      _DeudasPendientesSectionState();
}

class _DeudasPendientesSectionState extends State<DeudasPendientesSection> {
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

        return _DeudasContent(deudas: deudas);
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
  const _DeudasContent({required this.deudas});

  final DeudasResumen deudas;

  @override
  Widget build(BuildContext context) {
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
            onPressed:
                deudas.pedidos.isEmpty ? null : () => _showDeudas(context),
            child: const Text('Ver'),
          ),
        ],
      ),
    );
  }

  void _showDeudas(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Deudas pendientes'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children:
                    deudas.pedidos.take(8).map((pedido) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _DebtRow(
                          clienteAlias: pedido.clienteAlias,
                          balones: pedido.cantidadBalones,
                          pendienteCentavos: pedido.montoPendienteCentavos,
                        ),
                      );
                    }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }
}

class _DebtRow extends StatelessWidget {
  const _DebtRow({
    required this.clienteAlias,
    required this.balones,
    required this.pendienteCentavos,
  });

  final String clienteAlias;
  final int balones;
  final int pendienteCentavos;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clienteAlias,
                  style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text('$balones balones', style: text.titleMedium),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            formatSolesFromCentavos(pendienteCentavos),
            style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
