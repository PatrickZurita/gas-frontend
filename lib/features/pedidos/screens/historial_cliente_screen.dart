import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/cliente_info_card.dart';
import '../../../shared/compact_list_item.dart';
import '../../../shared/loading_card.dart';
import '../../../shared/message_box.dart';
import '../../../shared/status_badge.dart';
import '../../../shared/summary_card.dart';
import '../../clientes/models/cliente.dart';
import '../models/pedido.dart';
import '../pedido_service.dart';
import 'detalle_pedido_screen.dart';

class HistorialClienteScreen extends StatefulWidget {
  const HistorialClienteScreen({
    required this.cliente,
    required this.pedidoService,
    super.key,
  });

  final Cliente cliente;
  final PedidoService pedidoService;

  @override
  State<HistorialClienteScreen> createState() => _HistorialClienteScreenState();
}

class _HistorialClienteScreenState extends State<HistorialClienteScreen> {
  late Future<List<Pedido>> _pedidosFuture;

  @override
  void initState() {
    super.initState();
    _loadPedidos();
  }

  void _loadPedidos() {
    _pedidosFuture = widget.pedidoService.listarPedidosPorCliente(
      widget.cliente.id,
    );
  }

  Future<void> _refresh() async {
    setState(_loadPedidos);
    try {
      await _pedidosFuture;
    } catch (_) {
      // FutureBuilder renders the latest error state.
    }
  }

  Future<void> _abrirDetalle(Pedido pedido) async {
    final cambio = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => DetallePedidoScreen(
          pedido: pedido,
          pedidoService: widget.pedidoService,
          clienteAlias: widget.cliente.alias,
          onCambioPedido: _refresh,
        ),
      ),
    );
    if (cambio == true && mounted) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final direccion = widget.cliente.direccion ?? widget.cliente.alias;

    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: SafeArea(
        child: FutureBuilder<List<Pedido>>(
          future: _pedidosFuture,
          builder: (context, snapshot) {
            final children = <Widget>[
              Text(
                'Historial del cliente',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ClienteInfoCard(
                direccion: direccion,
                telefono: widget.cliente.telefono,
              ),
              const SizedBox(height: 20),
            ];

            if (snapshot.connectionState == ConnectionState.waiting) {
              children.add(
                const LoadingCard(
                  message: 'Cargando pedidos...',
                  icon: Icons.receipt_long_outlined,
                ),
              );
            } else if (snapshot.hasError) {
              children.add(MessageBox(message: _errorMessage(snapshot.error)));
            } else {
              final pedidos = snapshot.data ?? const <Pedido>[];
              if (pedidos.isEmpty) {
                children.add(
                  const MessageBox(
                    message: 'Este cliente aun no tiene pedidos.',
                  ),
                );
              } else {
                children.add(
                  _PedidoHistoryList(
                    pedidos: pedidos,
                    onPedidoTap: _abrirDetalle,
                  ),
                );
              }
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(20),
                physics: const AlwaysScrollableScrollPhysics(),
                children: children,
              ),
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
    return 'No se pudo cargar el historial.';
  }
}

class _PedidoHistoryList extends StatelessWidget {
  const _PedidoHistoryList({required this.pedidos, this.onPedidoTap});

  final List<Pedido> pedidos;
  final void Function(Pedido)? onPedidoTap;

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      padding: EdgeInsets.zero,
      borderRadius: 8,
      child: Column(
        children: [
          for (var index = 0; index < pedidos.length; index++)
            _PedidoHistoryRow(
              pedido: pedidos[index],
              showDivider: index < pedidos.length - 1,
              onTap:
                  onPedidoTap == null ? null : () => onPedidoTap!(pedidos[index]),
            ),
        ],
      ),
    );
  }
}

class _PedidoHistoryRow extends StatelessWidget {
  const _PedidoHistoryRow({
    required this.pedido,
    required this.showDivider,
    this.onTap,
  });

  final Pedido pedido;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final row = CompactListItem(
      title: _formatDate(pedido.fechaEntrega),
      trailing: 'S/ ${pedido.totalSoles.toStringAsFixed(2)}',
      showDivider: showDivider,
      maxTitleLines: 1,
      details: [
        Text(
          '${_balonesText(pedido.cantidadBalones)} ${pedido.pesoBalonKg} kg',
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
        if (!pedido.pagado && !pedido.esAnulado)
          Text(
            'Saldo S/ ${pedido.saldoPendiente.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 17, color: colors.onSurfaceVariant),
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

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
