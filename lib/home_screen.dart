import 'package:flutter/material.dart';

import 'features/clientes/cliente_service.dart';
import 'features/clientes/screens/buscar_cliente_screen.dart';
import 'features/pedidos/pedido_service.dart';
import 'shared/action_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.clienteService,
    required this.pedidoService,
    super.key,
  });

  final ClienteService clienteService;
  final PedidoService pedidoService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos de gas')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text(
                'Registrar pedidos',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Primero busca o crea el cliente.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 32),
              ActionButton(
                label: 'Nuevo pedido',
                icon: Icons.add_shopping_cart,
                primary: true,
                onPressed: () => _openBuscarCliente(context),
              ),
              const SizedBox(height: 16),
              ActionButton(
                label: 'Buscar cliente',
                icon: Icons.search,
                onPressed: () => _openBuscarCliente(context),
              ),
              const SizedBox(height: 16),
              ActionButton(
                label: 'Historial',
                icon: Icons.receipt_long,
                onPressed: () => _openBuscarCliente(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openBuscarCliente(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => BuscarClienteScreen(
              clienteService: clienteService,
              pedidoService: pedidoService,
            ),
      ),
    );
  }
}
