import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/action_button.dart';
import '../../pedidos/pedido_service.dart';
import '../cliente_service.dart';
import '../models/cliente.dart';
import 'cliente_seleccionado_screen.dart';
import 'crear_cliente_screen.dart';

class BuscarClienteScreen extends StatefulWidget {
  const BuscarClienteScreen({
    required this.clienteService,
    required this.pedidoService,
    super.key,
  });

  final ClienteService clienteService;
  final PedidoService pedidoService;

  @override
  State<BuscarClienteScreen> createState() => _BuscarClienteScreenState();
}

class _BuscarClienteScreenState extends State<BuscarClienteScreen> {
  final TextEditingController _queryController = TextEditingController();

  List<Cliente> _clientes = const [];
  bool _isLoading = false;
  bool _searched = false;
  String? _errorMessage;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searched = false;
        _clientes = const [];
        _errorMessage = 'Escribe una direccion o telefono.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searched = true;
      _errorMessage = null;
    });

    try {
      final clientes = await widget.clienteService.buscarClientes(query);
      if (!mounted) {
        return;
      }
      setState(() {
        _clientes = clientes;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _clientes = const [];
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _clientes = const [];
        _errorMessage = 'No se pudo buscar. Intenta otra vez.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _crearCliente() async {
    final created = await Navigator.of(context).push<Cliente>(
      MaterialPageRoute<Cliente>(
        builder:
            (_) => CrearClienteScreen(clienteService: widget.clienteService),
      ),
    );

    if (created != null && mounted) {
      _openClienteSeleccionado(created);
    }
  }

  void _openClienteSeleccionado(Cliente cliente) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => ClienteSeleccionadoScreen(
              cliente: cliente,
              pedidoService: widget.pedidoService,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar cliente')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Busca por direccion o telefono',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _queryController,
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(
                labelText: 'Direccion, alias o telefono',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (_) => _buscar(),
            ),
            const SizedBox(height: 16),
            ActionButton(
              label: _isLoading ? 'Buscando...' : 'Buscar',
              icon: Icons.search,
              primary: true,
              onPressed: _isLoading ? null : _buscar,
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null) _MessageBox(message: _errorMessage!),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              ..._buildResults(),
            const SizedBox(height: 20),
            ActionButton(
              label: 'Crear nuevo cliente',
              icon: Icons.person_add_alt_1,
              onPressed: _crearCliente,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildResults() {
    if (_clientes.isEmpty && _searched && _errorMessage == null) {
      return const [
        _MessageBox(message: 'No se encontraron clientes.'),
        SizedBox(height: 8),
      ];
    }

    return _clientes
        .map(
          (cliente) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ClienteListItem(
              cliente: cliente,
              onTap: () => _openClienteSeleccionado(cliente),
            ),
          ),
        )
        .toList();
  }
}

class _ClienteListItem extends StatelessWidget {
  const _ClienteListItem({required this.cliente, required this.onTap});

  final Cliente cliente;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final direccion = cliente.direccion ?? cliente.alias;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        minVerticalPadding: 18,
        leading: const Icon(Icons.person, size: 32),
        title: Text(
          direccion,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(cliente.telefono, style: const TextStyle(fontSize: 18)),
        trailing: const Icon(Icons.chevron_right, size: 32),
        onTap: onTap,
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
