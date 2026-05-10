import 'package:flutter/material.dart';

import '../../../features/pedidos/pedido_service.dart';
import '../../../features/pedidos/screens/historial_cliente_screen.dart';
import '../../../features/pedidos/screens/registrar_pedido_screen.dart';
import '../../../features/stock/services/stock_service.dart';
import '../../../shared/action_button.dart';
import '../models/cliente.dart';

class ClienteSeleccionadoScreen extends StatelessWidget {
  const ClienteSeleccionadoScreen({
    required this.cliente,
    required this.pedidoService,
    required this.stockService,
    super.key,
  });

  final Cliente cliente;
  final PedidoService pedidoService;
  final StockService stockService;

  @override
  Widget build(BuildContext context) {
    final direccion = cliente.direccion ?? cliente.alias;

    return Scaffold(
      appBar: AppBar(title: const Text('Cliente seleccionado')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Cliente seleccionado',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _InfoRow(label: 'Direccion', value: direccion),
              const SizedBox(height: 12),
              _InfoRow(label: 'Telefono', value: cliente.telefono),
              const Spacer(),
              ActionButton(
                label: 'Registrar pedido',
                icon: Icons.add_shopping_cart,
                primary: true,
                onPressed: () => _openRegistrarPedido(context),
              ),
              const SizedBox(height: 12),
              ActionButton(
                label: 'Ver historial',
                icon: Icons.receipt_long,
                onPressed: () => _openHistorial(context),
              ),
              const SizedBox(height: 12),
              ActionButton(
                label: 'Volver',
                icon: Icons.arrow_back,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openRegistrarPedido(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => RegistrarPedidoScreen(
              cliente: cliente,
              pedidoService: pedidoService,
              stockService: stockService,
            ),
      ),
    );
  }

  void _openHistorial(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => HistorialClienteScreen(
              cliente: cliente,
              pedidoService: pedidoService,
            ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

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
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
