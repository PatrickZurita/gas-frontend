import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/action_button.dart';
import '../../../shared/cliente_list_tile.dart';
import '../../../shared/loading_card.dart';
import '../../../shared/message_box.dart';
import '../../../shared/section_title.dart';
import '../../../shared/summary_card.dart';
import '../../pedidos/pedido_service.dart';
import '../../stock/services/stock_service.dart';
import '../cliente_service.dart';
import '../models/cliente.dart';
import '../models/cliente_reciente.dart';
import 'cliente_seleccionado_screen.dart';
import 'crear_cliente_screen.dart';

class BuscarClienteScreen extends StatefulWidget {
  const BuscarClienteScreen({
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
  State<BuscarClienteScreen> createState() => _BuscarClienteScreenState();
}

class _BuscarClienteScreenState extends State<BuscarClienteScreen> {
  final TextEditingController _queryController = TextEditingController();

  static const int _minSearchLength = 2;

  late Future<List<ClienteReciente>> _clientesRecientesFuture;
  List<Cliente> _clientes = const [];
  bool _isLoading = false;
  bool _searched = false;
  String? _errorMessage;
  Timer? _debounce;
  int _searchToken = 0;

  @override
  void initState() {
    super.initState();
    _clientesRecientesFuture = widget.clienteService.obtenerClientesRecientes(
      limit: 5,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    final query = _queryController.text.trim();
    _debounce?.cancel();

    if (query.isEmpty) {
      setState(() {
        _searched = false;
        _clientes = const [];
        _errorMessage = null;
      });
      return;
    }

    if (query.length < _minSearchLength) {
      setState(() {
        _searched = false;
        _clientes = const [];
        _errorMessage = null;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 350), () {
      _buscar(auto: true);
    });
  }

  Future<void> _buscar({bool auto = false}) async {
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searched = false;
        _clientes = const [];
        _errorMessage = auto ? null : 'Escribe una direccion o telefono.';
      });
      return;
    }

    if (query.length < _minSearchLength) {
      setState(() {
        _searched = false;
        _clientes = const [];
        _errorMessage =
            auto ? null : 'Escribe al menos $_minSearchLength caracteres.';
      });
      return;
    }

    final token = ++_searchToken;
    setState(() {
      _isLoading = true;
      _searched = true;
      _errorMessage = null;
    });

    try {
      final clientes = await widget.clienteService.buscarClientes(query);
      if (!mounted || token != _searchToken) {
        return;
      }
      setState(() {
        _clientes = clientes;
      });
    } on ApiException catch (error) {
      if (!mounted || token != _searchToken) {
        return;
      }
      setState(() {
        _clientes = const [];
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted || token != _searchToken) {
        return;
      }
      setState(() {
        _clientes = const [];
        _errorMessage = 'No se pudo buscar. Intenta otra vez.';
      });
    } finally {
      if (mounted && token == _searchToken) {
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
              stockService: widget.stockService,
              onPedidoGuardado: widget.onPedidoGuardado,
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
            const SectionTitle(title: 'Busca por direccion o telefono'),
            const SizedBox(height: 16),
            TextField(
              controller: _queryController,
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(
                labelText: 'Direccion, alias o telefono',
                helperText: 'Busca desde 2 letras',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _onQueryChanged,
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
            if (!_searched && _errorMessage == null) ...[
              _ClientesRecientesSection(
                future: _clientesRecientesFuture,
                onTap:
                    (clienteReciente) =>
                        _openClienteSeleccionado(clienteReciente.toCliente()),
              ),
              const SizedBox(height: 16),
            ],
            if (_errorMessage != null) MessageBox(message: _errorMessage!),
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
        MessageBox(message: 'No se encontraron clientes.'),
        SizedBox(height: 8),
      ];
    }

    return _clientes
        .map(
          (cliente) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ClienteListTile(
              direccion: cliente.direccion ?? cliente.alias,
              telefono: cliente.telefono,
              onTap: () => _openClienteSeleccionado(cliente),
            ),
          ),
        )
        .toList();
  }
}

class _ClientesRecientesSection extends StatelessWidget {
  const _ClientesRecientesSection({required this.future, required this.onTap});

  final Future<List<ClienteReciente>> future;
  final ValueChanged<ClienteReciente> onTap;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ClienteReciente>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingCard(
            message: 'Cargando clientes recientes...',
            icon: Icons.history,
          );
        }

        if (snapshot.hasError) {
          return const SummaryCard(
            padding: EdgeInsets.all(14),
            borderRadius: 12,
            child: MessageBox(message: 'No se pudo cargar clientes recientes.'),
          );
        }

        final recientes = snapshot.data ?? const <ClienteReciente>[];
        return SummaryCard(
          padding: const EdgeInsets.all(14),
          borderRadius: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clientes recientes',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              if (recientes.isEmpty)
                Text(
                  'Aun no hay clientes recientes.',
                  style: Theme.of(context).textTheme.titleMedium,
                )
              else
                ...recientes
                    .take(5)
                    .map(
                      (cliente) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ClienteListTile(
                          direccion: cliente.direccion,
                          telefono: cliente.telefono,
                          recent: true,
                          onTap: () => onTap(cliente),
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}

