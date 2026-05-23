import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/action_button.dart';
import '../../../shared/cliente_list_tile.dart';
import '../../../shared/message_box.dart';
import '../../pedidos/pedido_service.dart';
import '../../stock/services/stock_service.dart';
import '../cliente_service.dart';
import '../models/cliente.dart';
import 'cliente_seleccionado_screen.dart';
import 'crear_cliente_screen.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({
    required this.clienteService,
    required this.pedidoService,
    required this.stockService,
    this.onPedidoGuardado,
    super.key,
  });

  final ClienteService clienteService;
  final PedidoService pedidoService;
  final StockService stockService;
  final Future<void> Function()? onPedidoGuardado;

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final TextEditingController _queryController = TextEditingController();
  Timer? _debounce;
  Future<List<Cliente>>? _clientesFuture;
  String _activeQuery = '';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  void _reload({String? query}) {
    final q = query ?? _activeQuery;
    setState(() {
      _activeQuery = q;
      _clientesFuture = widget.clienteService.listarClientes(query: q);
    });
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _reload(query: value.trim());
    });
  }

  Future<void> _abrirCliente(Cliente cliente) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ClienteSeleccionadoScreen(
          cliente: cliente,
          pedidoService: widget.pedidoService,
          stockService: widget.stockService,
          onPedidoGuardado: widget.onPedidoGuardado,
        ),
      ),
    );
  }

  Future<void> _crearCliente() async {
    final cliente = await Navigator.of(context).push<Cliente>(
      MaterialPageRoute<Cliente>(
        builder: (_) =>
            CrearClienteScreen(clienteService: widget.clienteService),
      ),
    );
    if (cliente != null && mounted) {
      _reload();
      await _abrirCliente(cliente);
    }
  }

  Future<void> _refresh() async {
    _reload();
    try {
      await _clientesFuture;
    } catch (_) {
      // FutureBuilder renders the latest error state.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: TextField(
                controller: _queryController,
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 20),
                decoration: const InputDecoration(
                  labelText: 'Buscar cliente',
                  hintText: 'Direccion, alias o telefono',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: _onQueryChanged,
                onSubmitted: (value) => _reload(query: value.trim()),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: FutureBuilder<List<Cliente>>(
                  future: _clientesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return ListView(
                        padding: const EdgeInsets.all(20),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          MessageBox(message: _errorMessage(snapshot.error)),
                        ],
                      );
                    }

                    final clientes = snapshot.data ?? const <Cliente>[];
                    if (clientes.isEmpty) {
                      return ListView(
                        padding: const EdgeInsets.all(20),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          MessageBox(
                            message: _activeQuery.isEmpty
                                ? 'Aun no hay clientes registrados.'
                                : 'No se encontraron clientes.',
                          ),
                        ],
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(20),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: clientes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final cliente = clientes[index];
                        return ClienteListTile(
                          direccion: cliente.direccion ?? cliente.alias,
                          telefono: cliente.telefono,
                          onTap: () => _abrirCliente(cliente),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: ActionButton(
                label: 'Crear nuevo cliente',
                icon: Icons.person_add_alt_1,
                onPressed: _crearCliente,
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
    return 'No se pudo cargar la lista de clientes.';
  }
}
