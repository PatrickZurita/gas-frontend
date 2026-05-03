import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gas_frontend/features/clientes/cliente_service.dart';
import 'package:gas_frontend/features/clientes/models/cliente.dart';
import 'package:gas_frontend/features/clientes/models/cliente_create_request.dart';
import 'package:gas_frontend/features/clientes/screens/buscar_cliente_screen.dart';
import 'package:gas_frontend/features/clientes/screens/crear_cliente_screen.dart';
import 'package:gas_frontend/features/clientes/screens/cliente_seleccionado_screen.dart';
import 'package:gas_frontend/features/pedidos/models/pedido.dart';
import 'package:gas_frontend/features/pedidos/models/pedido_create_request.dart';
import 'package:gas_frontend/features/pedidos/pedido_service.dart';
import 'package:gas_frontend/main.dart';

void main() {
  testWidgets('home screen shows MVP actions', (WidgetTester tester) async {
    await tester.pumpWidget(const GasApp());

    expect(find.text('Registrar pedidos'), findsOneWidget);
    expect(find.text('Nuevo pedido'), findsOneWidget);
    expect(find.text('Buscar cliente'), findsOneWidget);
    expect(find.text('Historial'), findsOneWidget);

    expect(find.byIcon(Icons.add_shopping_cart), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.receipt_long), findsOneWidget);
  });

  testWidgets('home opens client search from Buscar cliente', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GasApp());

    await tester.tap(find.text('Buscar cliente'));
    await tester.pumpAndSettle();

    expect(find.text('Busca por direccion o telefono'), findsOneWidget);
    expect(find.text('Crear nuevo cliente'), findsOneWidget);
  });

  testWidgets('client search selects a result', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: _SearchHost(
          clienteService: _FakeClienteService.withResults(),
          pedidoService: _FakePedidoService(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Higueras');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Buscar'));
    await tester.pumpAndSettle();

    expect(find.text('Las Higueras 371'), findsOneWidget);

    await tester.tap(find.text('Las Higueras 371'));
    await tester.pumpAndSettle();

    expect(find.text('Cliente seleccionado'), findsWidgets);
    expect(find.text('999888777'), findsOneWidget);
  });

  testWidgets('create client validates required fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: _CreateHost(service: _FakeClienteService.withResults()),
      ),
    );

    await tester.tap(find.text('Guardar cliente'));
    await tester.pump();

    expect(
      find.text('Escribe una direccion de al menos 3 caracteres.'),
      findsOneWidget,
    );
  });

  testWidgets('selected client opens order form and saves paid order', (
    WidgetTester tester,
  ) async {
    final pedidoService = _FakePedidoService();

    await tester.pumpWidget(
      MaterialApp(
        home: ClienteSeleccionadoScreen(
          cliente: const Cliente(
            id: 1,
            alias: 'Las Higueras 371',
            telefono: '999888777',
          ),
          pedidoService: pedidoService,
        ),
      ),
    );

    await tester.tap(find.text('Registrar pedido'));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo pedido'), findsOneWidget);
    expect(find.widgetWithText(TextField, '1'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, '55');
    await tester.tap(find.text('Guardar pedido'));
    await tester.pumpAndSettle();

    expect(find.text('Pedido guardado como pagado.'), findsOneWidget);
    expect(pedidoService.lastRequest?.clienteId, 1);
    expect(pedidoService.lastRequest?.cantidadBalones, 1);
    expect(pedidoService.lastRequest?.totalSoles, 55.0);
    expect(pedidoService.lastRequest?.pagado, isTrue);
  });

  testWidgets('selected client opens history and shows orders', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ClienteSeleccionadoScreen(
          cliente: const Cliente(
            id: 1,
            alias: 'Las Higueras 371',
            telefono: '999888777',
          ),
          pedidoService: _FakePedidoService.withHistory(),
        ),
      ),
    );

    await tester.tap(find.text('Ver historial'));
    await tester.pumpAndSettle();

    expect(find.text('Historial del cliente'), findsOneWidget);
    expect(find.text('16/01/2026'), findsOneWidget);
    expect(find.text('S/ 110.00'), findsOneWidget);
    expect(find.text('Si'), findsOneWidget);
    expect(find.text('S/ 0.00'), findsOneWidget);
  });

  testWidgets('history shows empty message when client has no orders', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ClienteSeleccionadoScreen(
          cliente: const Cliente(
            id: 1,
            alias: 'Las Higueras 371',
            telefono: '999888777',
          ),
          pedidoService: _FakePedidoService(),
        ),
      ),
    );

    await tester.tap(find.text('Ver historial'));
    await tester.pumpAndSettle();

    expect(find.text('Este cliente aun no tiene pedidos.'), findsOneWidget);
  });
}

class _SearchHost extends StatelessWidget {
  const _SearchHost({
    required this.clienteService,
    required this.pedidoService,
  });

  final ClienteService clienteService;
  final PedidoService pedidoService;

  @override
  Widget build(BuildContext context) {
    return BuscarClienteScreen(
      clienteService: clienteService,
      pedidoService: pedidoService,
    );
  }
}

class _CreateHost extends StatelessWidget {
  const _CreateHost({required this.service});

  final ClienteService service;

  @override
  Widget build(BuildContext context) {
    return CrearClienteScreen(clienteService: service);
  }
}

class _FakeClienteService implements ClienteService {
  _FakeClienteService.withResults()
    : _clientes = const [
        Cliente(id: 1, alias: 'Las Higueras 371', telefono: '999888777'),
      ];

  final List<Cliente> _clientes;

  @override
  Future<List<Cliente>> buscarClientes(String query, {int limit = 10}) async {
    return _clientes;
  }

  @override
  Future<Cliente> crearCliente(ClienteCreateRequest request) async {
    return Cliente(id: 2, alias: request.alias, telefono: request.telefono);
  }

  @override
  Future<Cliente> obtenerCliente(int id) async {
    return _clientes.first;
  }
}

class _FakePedidoService implements PedidoService {
  _FakePedidoService() : _history = const [];

  _FakePedidoService.withHistory()
    : _history = [
        Pedido(
          id: 2,
          clienteId: 1,
          direccionId: 1,
          createdAt: DateTime.parse('2026-01-16T10:33:46.613608-05:00'),
          fechaEntrega: DateTime.parse('2026-01-16'),
          cantidadBalones: 2,
          totalSoles: 110,
          pagado: true,
          saldoPendiente: 0,
        ),
      ];

  PedidoCreateRequest? lastRequest;
  final List<Pedido> _history;

  @override
  Future<Pedido> crearPedido(PedidoCreateRequest request) async {
    lastRequest = request;
    return Pedido(
      id: 1,
      clienteId: request.clienteId,
      direccionId: 1,
      createdAt: DateTime.parse('2026-01-16T10:45:03.084894-05:00'),
      fechaEntrega: DateTime.parse('2026-01-16'),
      cantidadBalones: request.cantidadBalones,
      totalSoles: request.totalSoles,
      pagado: request.pagado,
      saldoPendiente: request.pagado ? 0 : request.totalSoles,
    );
  }

  @override
  Future<List<Pedido>> listarPedidosPorCliente(int clienteId) async {
    return _history;
  }
}
