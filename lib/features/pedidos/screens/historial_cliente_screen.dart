import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../clientes/models/cliente.dart';
import '../models/pedido.dart';
import '../pedido_service.dart';

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
  late final Future<List<Pedido>> _pedidosFuture;

  @override
  void initState() {
    super.initState();
    _pedidosFuture = widget.pedidoService.listarPedidosPorCliente(
      widget.cliente.id,
    );
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
              _ClienteHeader(
                direccion: direccion,
                telefono: widget.cliente.telefono,
              ),
              const SizedBox(height: 20),
            ];

            if (snapshot.connectionState == ConnectionState.waiting) {
              children.addAll(const [
                SizedBox(height: 32),
                Center(child: CircularProgressIndicator()),
                SizedBox(height: 12),
                Center(
                  child: Text(
                    'Cargando pedidos...',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ]);
            } else if (snapshot.hasError) {
              children.add(_MessageBox(message: _errorMessage(snapshot.error)));
            } else {
              final pedidos = snapshot.data ?? const <Pedido>[];
              if (pedidos.isEmpty) {
                children.add(
                  const _MessageBox(
                    message: 'Este cliente aun no tiene pedidos.',
                  ),
                );
              } else {
                children.addAll(
                  pedidos.map(
                    (pedido) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PedidoCard(pedido: pedido),
                    ),
                  ),
                );
              }
            }

            return ListView(
              padding: const EdgeInsets.all(20),
              children: children,
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

class _ClienteHeader extends StatelessWidget {
  const _ClienteHeader({required this.direccion, required this.telefono});

  final String direccion;
  final String telefono;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cliente', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(
            direccion,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(telefono, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}

class _PedidoCard extends StatelessWidget {
  const _PedidoCard({required this.pedido});

  final Pedido pedido;

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
            _formatDate(pedido.fechaEntrega),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _InfoLine(label: 'Balones', value: '${pedido.cantidadBalones}'),
          _InfoLine(
            label: 'Total',
            value: 'S/ ${pedido.totalSoles.toStringAsFixed(2)}',
          ),
          _InfoLine(label: 'Pagado', value: pedido.pagado ? 'Si' : 'No'),
          _InfoLine(
            label: 'Saldo',
            value: 'S/ ${pedido.saldoPendiente.toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
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
          Expanded(child: Text(label, style: const TextStyle(fontSize: 18))),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
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
