import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gas_frontend/core/network/api_exception.dart';
import 'package:gas_frontend/features/clientes/cliente_service.dart';
import 'package:gas_frontend/features/clientes/models/cliente.dart';
import 'package:gas_frontend/features/clientes/models/cliente_create_request.dart';
import 'package:gas_frontend/features/clientes/models/cliente_reciente.dart';
import 'package:gas_frontend/features/clientes/screens/buscar_cliente_screen.dart';
import 'package:gas_frontend/features/clientes/screens/crear_cliente_screen.dart';
import 'package:gas_frontend/features/clientes/screens/cliente_seleccionado_screen.dart';
import 'package:gas_frontend/features/pedidos/models/pedido.dart';
import 'package:gas_frontend/features/pedidos/models/pedido_create_request.dart';
import 'package:gas_frontend/features/pedidos/models/pedido_update_request.dart';
import 'package:gas_frontend/features/pedidos/pedido_service.dart';
import 'package:gas_frontend/features/reportes/models/deudas_resumen.dart';
import 'package:gas_frontend/features/reportes/models/pedido_reporte.dart';
import 'package:gas_frontend/features/reportes/models/reporte_diario.dart';
import 'package:gas_frontend/features/reportes/models/reporte_mensual.dart';
import 'package:gas_frontend/features/reportes/models/reporte_semanal.dart';
import 'package:gas_frontend/features/reportes/services/reportes_service.dart';
import 'package:gas_frontend/features/stock/models/catalogo_item.dart';
import 'package:gas_frontend/features/stock/models/stock_continuar_preview.dart';
import 'package:gas_frontend/features/stock/models/stock_dia.dart';
import 'package:gas_frontend/features/stock/models/stock_operacion.dart';
import 'package:gas_frontend/features/stock/models/stock_requests.dart';
import 'package:gas_frontend/features/stock/models/stock_resumen.dart';
import 'package:gas_frontend/features/stock/services/stock_service.dart';
import 'package:gas_frontend/home_screen.dart';

void main() {
  testWidgets('home screen shows MVP actions', (WidgetTester tester) async {
    await _pumpHome(tester);
    await tester.pumpAndSettle();

    expect(find.text('Registrar pedido'), findsOneWidget);
    expect(find.text('Clientes'), findsOneWidget);
    expect(find.text('Pedidos'), findsWidgets);
    expect(find.text('Reportes'), findsOneWidget);
    expect(find.text('Historial'), findsNothing);
    await tester.scrollUntilVisible(find.text('Stock de hoy'), 300);
    expect(find.text('Stock de hoy'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Resumen del dia'), 300);
    expect(find.text('Resumen del dia'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Deudas'), 300);
    expect(find.text('Deudas'), findsOneWidget);
  });

  testWidgets('home opens clients catalog from Clientes button', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Clientes'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Clientes'), findsOneWidget);
    expect(find.text('Crear nuevo cliente'), findsOneWidget);
  });

  testWidgets('home opens orders screen from Pedidos button', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester, reportesService: _FakeReportesService.withData());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pedidos').first);
    await tester.pumpAndSettle();

    expect(find.text('Pedidos de hoy'), findsWidgets);
    expect(find.text('Clientes recientes'), findsNothing);
    expect(find.text('Las Higueras 371'), findsOneWidget);
    expect(find.text('Pendiente'), findsWidgets);
  });

  testWidgets('home shows empty reports summary', (WidgetTester tester) async {
    await _pumpHome(tester, reportesService: _FakeReportesService.empty());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Resumen del dia'), 300);

    expect(find.text('Total vendido'), findsOneWidget);
    expect(find.text('S/ 0.00'), findsWidgets);
    expect(find.text('Aun no hay pedidos hoy.'), findsOneWidget);
  });

  testWidgets('home shows stock not started state', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester, stockService: _FakeStockService.notStarted());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Stock de hoy'), 300);

    expect(find.text('Stock de hoy'), findsOneWidget);
    expect(
      find.text('Todavia no se registro cuantos balones hay en el deposito.'),
      findsOneWidget,
    );
    expect(find.text('Registrar stock de hoy'), findsOneWidget);
  });

  testWidgets('home shows stock summary with data', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester, stockService: _FakeStockService.withData());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Balones disponibles'), 300);

    expect(find.text('Balones disponibles'), findsOneWidget);
    expect(find.text('29'), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('Vendidos hoy'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Actualizar stock actual'), findsOneWidget);
    expect(find.text('Agregar entrada'), findsOneWidget);
  });

  testWidgets('home shows manual stock adjustment with clear label', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester, stockService: _FakeStockService.withAdjustment());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Balones disponibles'), 300);

    expect(find.text('Ajuste manual'), findsOneWidget);
    expect(find.text('+1'), findsOneWidget);
    expect(find.text('Ajustes'), findsNothing);
  });

  testWidgets('home shows stock error state', (WidgetTester tester) async {
    await _pumpHome(tester, stockService: _FakeStockService.failure());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Stock de hoy'), 300);

    expect(find.text('No se pudo cargar el stock.'), findsOneWidget);
    expect(find.text('Reintentar'), findsWidgets);
  });

  testWidgets('home shows reports summary with centavos money', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester, reportesService: _FakeReportesService.withData());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Resumen del dia'), 300);

    expect(find.text('S/ 165.00'), findsOneWidget);
    expect(find.text('S/ 110.00'), findsOneWidget);
    expect(find.text('S/ 55.00'), findsOneWidget);
    expect(
      find.text('2 pedidos registrados hoy. Toca para verlos.'),
      findsOneWidget,
    );
  });

  testWidgets('tapping reports summary opens day orders list', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester, reportesService: _FakeReportesService.withData());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Resumen del dia'), 300);

    await tester.tap(find.text('Resumen del dia'));
    await tester.pumpAndSettle();

    expect(find.text('Pedidos de hoy'), findsWidgets);
    expect(find.text('Todos'), findsOneWidget);
    expect(find.text('Pagados'), findsOneWidget);
    expect(find.text('Pendientes'), findsOneWidget);
    expect(find.text('Las Higueras 371'), findsOneWidget);
  });

  testWidgets('home refreshes backend data after returning from pedidos', (
    WidgetTester tester,
  ) async {
    final reportesService = _FakeReportesService.withData();
    final stockService = _FakeStockService.withData();

    await _pumpHome(
      tester,
      reportesService: reportesService,
      stockService: stockService,
    );
    await tester.pumpAndSettle();

    expect(reportesService.summaryCalls, 1);
    expect(reportesService.deudasCalls, 1);
    expect(stockService.summaryCalls, 1);

    await tester.tap(find.text('Pedidos').first);
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(reportesService.summaryCalls, 3);
    expect(reportesService.deudasCalls, 2);
    expect(stockService.summaryCalls, 2);
  });

  testWidgets('pull to refresh reloads home sections from backend', (
    WidgetTester tester,
  ) async {
    final reportesService = _FakeReportesService.withData();
    final stockService = _FakeStockService.withData();

    await _pumpHome(
      tester,
      reportesService: reportesService,
      stockService: stockService,
    );
    await tester.pumpAndSettle();

    expect(reportesService.summaryCalls, 1);
    expect(reportesService.deudasCalls, 1);
    expect(stockService.summaryCalls, 1);

    await tester.drag(find.byType(ListView).first, const Offset(0, 300));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(reportesService.summaryCalls, 2);
    expect(reportesService.deudasCalls, 2);
    expect(stockService.summaryCalls, 2);
  });

  testWidgets('day orders filters paid and pending orders', (
    WidgetTester tester,
  ) async {
    await _pumpHome(
      tester,
      reportesService: _FakeReportesService.withMixedOrders(),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pedidos').first);
    await tester.pumpAndSettle();

    expect(find.text('Pedido pagado'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Pedido pendiente'), 300);
    expect(find.text('Pedido pendiente'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, 500));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pagados'));
    await tester.pumpAndSettle();

    expect(find.text('Pedido pagado'), findsOneWidget);
    expect(find.text('Pedido pendiente'), findsNothing);

    await tester.tap(find.text('Pendientes'));
    await tester.pumpAndSettle();

    expect(find.text('Pedido pagado'), findsNothing);
    expect(find.text('Pedido pendiente'), findsOneWidget);
  });

  testWidgets('home shows reports error state', (WidgetTester tester) async {
    await _pumpHome(tester, reportesService: _FakeReportesService.failure());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('No se pudo cargar el resumen.'),
      300,
    );

    expect(find.text('No se pudo cargar el resumen.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('home shows empty debts section', (WidgetTester tester) async {
    await _pumpHome(tester, reportesService: _FakeReportesService.empty());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Deudas'), 300);

    expect(find.text('Deudas'), findsOneWidget);
    expect(find.text('Sin deudas pendientes'), findsOneWidget);
    expect(find.text('S/ 0.00'), findsWidgets);
  });

  testWidgets('home shows debts section with pending orders', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester, reportesService: _FakeReportesService.withData());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Deudas'), 300);

    expect(find.text('Deudas'), findsOneWidget);
    expect(find.text('1 pedidos por cobrar'), findsOneWidget);
    expect(find.text('S/ 55.00'), findsWidgets);
    expect(find.text('Ver'), findsOneWidget);

    await tester.tap(find.text('Ver'));
    await tester.pumpAndSettle();

    expect(find.text('Deudas pendientes'), findsOneWidget);
    expect(find.text('Las Higueras 371'), findsOneWidget);
  });

  testWidgets('home shows debts error state', (WidgetTester tester) async {
    await _pumpHome(
      tester,
      reportesService: _FakeReportesService.deudasFailure(),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Deudas pendientes'), 300);

    expect(find.text('No se pudo cargar las deudas.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('client search selects a result', (WidgetTester tester) async {
    final clienteService = _FakeClienteService.withResults();
    await tester.pumpWidget(
      MaterialApp(
        home: _SearchHost(
          clienteService: clienteService,
          pedidoService: _FakePedidoService(),
          stockService: _FakeStockService.notStarted(),
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
    expect(clienteService.lastQuery, 'Higueras');
  });

  testWidgets('client search suggests results while typing', (
    WidgetTester tester,
  ) async {
    final clienteService = _FakeClienteService.withResults();
    await tester.pumpWidget(
      MaterialApp(
        home: _SearchHost(
          clienteService: clienteService,
          pedidoService: _FakePedidoService(),
          stockService: _FakeStockService.notStarted(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'L');
    await tester.pump(const Duration(milliseconds: 400));
    expect(clienteService.searchCalls, 0);

    await tester.enterText(find.byType(TextField), 'Las');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(clienteService.lastQuery, 'Las');
    expect(find.text('Las Higueras 371'), findsOneWidget);
  });

  testWidgets('client search shows empty recent clients state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: _SearchHost(
          clienteService: _FakeClienteService.empty(),
          pedidoService: _FakePedidoService(),
          stockService: _FakeStockService.notStarted(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Clientes recientes'), findsOneWidget);
    expect(find.text('Aun no hay clientes recientes.'), findsOneWidget);
  });

  testWidgets('client search selects a recent client', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: _SearchHost(
          clienteService: _FakeClienteService.withRecentClients(),
          pedidoService: _FakePedidoService(),
          stockService: _FakeStockService.notStarted(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Clientes recientes'), findsOneWidget);
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
            id: '1',
            alias: 'Las Higueras 371',
            telefono: '999888777',
          ),
          pedidoService: pedidoService,
          stockService: _FakeStockService.notStarted(),
        ),
      ),
    );

    await tester.tap(find.text('Registrar pedido'));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo pedido'), findsOneWidget);
    expect(find.widgetWithText(TextField, '1'), findsOneWidget);
    expect(find.text('Peso del balon'), findsOneWidget);
    expect(find.text('10 kg'), findsAtLeastNWidgets(1));
    expect(find.text('45 kg'), findsAtLeastNWidgets(1));
    await tester.drag(find.byType(ListView), const Offset(0, -250));
    await tester.pumpAndSettle();
    expect(find.text('Petroperu'), findsAtLeastNWidgets(1));
    expect(find.widgetWithText(TextField, 'Precio por balon'), findsOneWidget);
    expect(find.text('No escribas el total'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.widgetWithText(TextField, '2'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    expect(find.widgetWithText(TextField, '1'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Precio por balon'),
      '55',
    );
    await tester.drag(find.byType(ListView), const Offset(0, -250));
    await tester.pumpAndSettle();
    expect(find.text('Normal'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pump();
    await tester.tap(find.text('Guardar pedido').last);
    await tester.pumpAndSettle();

    expect(find.text('Pedido guardado'), findsOneWidget);
    expect(find.text('Cliente seleccionado'), findsWidgets);
    expect(pedidoService.lastRequest?.clienteId, '1');
    expect(pedidoService.lastRequest?.cantidadBalones, 1);
    expect(pedidoService.lastRequest?.marcaBalon, 'PETROPERU');
    expect(pedidoService.lastRequest?.tipoBalon, 'NORMAL');
    expect(pedidoService.lastRequest?.precioUnitarioCentavos, 5500);
    expect(pedidoService.lastRequest?.montoTotalCentavos, 5500);
    expect(pedidoService.lastRequest?.montoPendienteCentavos, 0);
    expect(pedidoService.lastRequest?.pagado, isTrue);
    expect(pedidoService.createCalls, 1);
  });

  testWidgets('order form prevents double submit while saving', (
    WidgetTester tester,
  ) async {
    final pedidoService = _FakePedidoService(
      delay: const Duration(milliseconds: 150),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ClienteSeleccionadoScreen(
          cliente: const Cliente(
            id: '1',
            alias: 'Las Higueras 371',
            telefono: '999888777',
          ),
          pedidoService: pedidoService,
          stockService: _FakeStockService.notStarted(),
        ),
      ),
    );

    await tester.tap(find.text('Registrar pedido'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Precio por balon'),
      '55',
    );
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pump();

    final saveButton = find.text('Guardar pedido').last;
    await tester.tap(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text('Guardando...'), findsOneWidget);
    await tester.pumpAndSettle();

    expect(pedidoService.createCalls, 1);
  });

  testWidgets('selected client opens history and shows orders', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ClienteSeleccionadoScreen(
          cliente: const Cliente(
            id: '1',
            alias: 'Las Higueras 371',
            telefono: '999888777',
          ),
          pedidoService: _FakePedidoService.withHistory(),
          stockService: _FakeStockService.notStarted(),
        ),
      ),
    );

    await tester.tap(find.text('Ver historial'));
    await tester.pumpAndSettle();

    expect(find.text('Historial del cliente'), findsOneWidget);
    expect(find.text('16/01/2026'), findsOneWidget);
    expect(find.text('S/ 110.00'), findsOneWidget);
    expect(find.text('Pagado'), findsOneWidget);
  });

  testWidgets('history shows empty message when client has no orders', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ClienteSeleccionadoScreen(
          cliente: const Cliente(
            id: '1',
            alias: 'Las Higueras 371',
            telefono: '999888777',
          ),
          pedidoService: _FakePedidoService(),
          stockService: _FakeStockService.notStarted(),
        ),
      ),
    );

    await tester.tap(find.text('Ver historial'));
    await tester.pumpAndSettle();

    expect(find.text('Este cliente aun no tiene pedidos.'), findsOneWidget);
  });
}

Future<void> _pumpHome(
  WidgetTester tester, {
  ReportesService? reportesService,
  StockService? stockService,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: HomeScreen(
        clienteService: _FakeClienteService.withResults(),
        pedidoService: _FakePedidoService(),
        reportesService: reportesService ?? _FakeReportesService.empty(),
        stockService: stockService ?? _FakeStockService.notStarted(),
      ),
    ),
  );
}

class _SearchHost extends StatelessWidget {
  const _SearchHost({
    required this.clienteService,
    required this.pedidoService,
    required this.stockService,
  });

  final ClienteService clienteService;
  final PedidoService pedidoService;
  final StockService stockService;

  @override
  Widget build(BuildContext context) {
    return BuscarClienteScreen(
      clienteService: clienteService,
      pedidoService: pedidoService,
      stockService: stockService,
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
        Cliente(id: '1', alias: 'Las Higueras 371', telefono: '999888777'),
      ],
      _recientes = const [];

  _FakeClienteService.withRecentClients()
    : _clientes = const [],
      _recientes = [
        ClienteReciente(
          id: '1',
          alias: 'Las Higueras 371',
          telefono: '999888777',
          direccion: 'Las Higueras 371',
          ultimoPedidoFecha: DateTime(2026, 1, 16),
          ultimoTotalCentavos: 5500,
        ),
      ];

  _FakeClienteService.empty() : _clientes = const [], _recientes = const [];

  final List<Cliente> _clientes;
  final List<ClienteReciente> _recientes;
  int searchCalls = 0;
  String? lastQuery;

  @override
  Future<List<Cliente>> buscarClientes(String query, {int limit = 10}) async {
    searchCalls++;
    lastQuery = query;
    return _clientes;
  }

  @override
  Future<Cliente> crearCliente(ClienteCreateRequest request) async {
    return Cliente(id: '2', alias: request.alias, telefono: request.telefono);
  }

  @override
  Future<Cliente> obtenerCliente(String id) async {
    return _clientes.first;
  }

  @override
  Future<List<ClienteReciente>> obtenerClientesRecientes({
    int limit = 5,
  }) async {
    return _recientes.take(limit).toList();
  }

  @override
  Future<List<Cliente>> listarClientes({
    String? query,
    int limit = 100,
    int offset = 0,
  }) async {
    if (query == null || query.isEmpty) {
      return _clientes;
    }
    final q = query.toLowerCase();
    return _clientes
        .where(
          (c) =>
              (c.direccion ?? c.alias).toLowerCase().contains(q) ||
              c.telefono.contains(q),
        )
        .toList();
  }
}

class _FakePedidoService implements PedidoService {
  _FakePedidoService({this.delay = Duration.zero}) : _history = const [];

  _FakePedidoService.withHistory()
    : delay = Duration.zero,
      _history = [
        Pedido(
          id: '2',
          clienteId: '1',
          direccionId: '1',
          createdAt: DateTime.parse('2026-01-16T10:33:46.613608-05:00'),
          fechaEntrega: DateTime.parse('2026-01-16'),
          cantidadBalones: 2,
          totalSoles: 110,
          pagado: true,
          saldoPendiente: 0,
          marcaBalon: 'PETROPERU',
          tipoBalon: 'NORMAL',
          precioUnitarioCentavos: 5500,
          montoTotalCentavos: 11000,
          montoPendienteCentavos: 0,
        ),
      ];

  PedidoCreateRequest? lastRequest;
  int createCalls = 0;
  final Duration delay;
  final List<Pedido> _history;

  @override
  Future<Pedido> crearPedido(PedidoCreateRequest request) async {
    createCalls++;
    if (delay != Duration.zero) {
      await Future<void>.delayed(delay);
    }
    lastRequest = request;
    return Pedido(
      id: '1',
      clienteId: request.clienteId,
      direccionId: '1',
      createdAt: DateTime.parse('2026-01-16T10:45:03.084894-05:00'),
      fechaEntrega: DateTime.parse('2026-01-16'),
      cantidadBalones: request.cantidadBalones,
      totalSoles: request.legacyTotalSoles,
      pagado: request.pagado,
      saldoPendiente: request.pagado ? 0 : request.legacyTotalSoles,
      marcaBalon: request.marcaBalon,
      tipoBalon: request.tipoBalon,
      precioUnitarioCentavos: request.precioUnitarioCentavos,
      montoTotalCentavos: request.montoTotalCentavos,
      montoPendienteCentavos: request.montoPendienteCentavos,
    );
  }

  @override
  Future<List<Pedido>> listarPedidosPorCliente(String clienteId) async {
    return _history;
  }

  @override
  Future<Pedido> anularPedido(String pedidoId, {String? motivo}) async {
    return Pedido(
      id: pedidoId,
      clienteId: '1',
      direccionId: '1',
      createdAt: DateTime.parse('2026-01-16T10:45:03.084894-05:00'),
      fechaEntrega: DateTime.parse('2026-01-16'),
      cantidadBalones: 1,
      totalSoles: 55,
      pagado: true,
      saldoPendiente: 0,
      marcaBalon: 'PETROPERU',
      tipoBalon: 'NORMAL',
      precioUnitarioCentavos: 5500,
      montoTotalCentavos: 5500,
      montoPendienteCentavos: 0,
      estado: PedidoEstado.anulado,
      anuladoAt: DateTime.parse('2026-01-16T11:00:00-05:00'),
      anuladoMotivo: motivo,
    );
  }

  @override
  Future<Pedido> editarPedido(
    String pedidoId,
    PedidoUpdateRequest request,
  ) async {
    return Pedido(
      id: pedidoId,
      clienteId: '1',
      direccionId: '1',
      createdAt: DateTime.parse('2026-01-16T10:45:03.084894-05:00'),
      fechaEntrega: DateTime.parse('2026-01-16'),
      cantidadBalones: request.cantidadBalones ?? 1,
      totalSoles: (request.montoTotalCentavos ?? 5500) / 100,
      pagado: request.pagado ?? true,
      saldoPendiente: (request.montoPendienteCentavos ?? 0) / 100,
      marcaBalon: request.marcaBalon ?? 'PETROPERU',
      tipoBalon: request.tipoBalon ?? 'NORMAL',
      precioUnitarioCentavos: request.precioUnitarioCentavos,
      montoTotalCentavos: request.montoTotalCentavos,
      montoPendienteCentavos: request.montoPendienteCentavos,
      pesoBalonKg: request.pesoBalonKg ?? 10,
    );
  }
}

class _FakeStockService implements StockService {
  _FakeStockService.notStarted()
    : _stock = StockResumen(
        fecha: DateTime.parse('2026-01-16'),
        stockIniciado: false,
        stockInicial: null,
        entradas: 0,
        salidas: 0,
        ajustes: 0,
        stockActual: null,
        stockFinalFisico: null,
        cerrado: false,
      ),
      _error = null;

  _FakeStockService.withData()
    : _stock = StockResumen(
        fecha: DateTime.parse('2026-01-16'),
        stockIniciado: true,
        stockInicial: 30,
        entradas: 0,
        salidas: 1,
        ajustes: 0,
        stockActual: 29,
        stockFinalFisico: null,
        cerrado: false,
      ),
      _error = null;

  _FakeStockService.withAdjustment()
    : _stock = StockResumen(
        fecha: DateTime.parse('2026-01-16'),
        stockIniciado: true,
        stockInicial: 40,
        entradas: 0,
        salidas: 16,
        ajustes: 1,
        stockActual: 25,
        stockFinalFisico: null,
        cerrado: false,
      ),
      _error = null;

  _FakeStockService.failure()
    : _stock = null,
      _error = const ApiException(message: 'No se pudo cargar el stock.');

  final StockResumen? _stock;
  final ApiException? _error;
  int summaryCalls = 0;

  @override
  Future<StockResumen> obtenerResumenHoy() async {
    summaryCalls++;
    final error = _error;
    if (error != null) {
      throw error;
    }
    return _stock!;
  }

  @override
  Future<StockDia> obtenerStockDia(DateTime fecha) async {
    return StockDia(
      fecha: fecha,
      stockIniciado: true,
      stockInicial: 30,
      entradas: 0,
      salidas: 1,
      ajustes: 0,
      stockActual: 29,
      stockFinalFisico: null,
      cerrado: false,
      movimientos: const [],
    );
  }

  @override
  Future<StockOperacion> iniciarDia(StockIniciarDiaRequest request) async {
    return StockOperacion(
      fecha: request.fecha,
      tipo: 'INICIO_DIA',
      cantidadDelta: request.stockInicial,
      stockActual: request.stockInicial,
      observacion: request.observacion,
    );
  }

  @override
  Future<StockOperacion> registrarEntrada(StockEntradaRequest request) async {
    return StockOperacion(
      fecha: request.fecha,
      tipo: 'ENTRADA',
      cantidadDelta: request.cantidad,
      stockActual: request.cantidad,
      observacion: request.observacion,
    );
  }

  @override
  Future<StockOperacion> ajustarStock(StockAjusteRequest request) async {
    return StockOperacion(
      fecha: request.fecha,
      tipo: 'AJUSTE',
      cantidadDelta: 0,
      stockActual: request.stockFisico,
      observacion: request.observacion,
    );
  }

  @override
  Future<List<CatalogoItem>> obtenerTiposBalon() async {
    return const [
      CatalogoItem(codigo: 'NORMAL', nombre: 'Normal'),
      CatalogoItem(codigo: 'PREMIUM', nombre: 'Premium'),
    ];
  }

  @override
  Future<List<CatalogoItem>> obtenerMarcasBalon() async {
    return const [
      CatalogoItem(codigo: 'PETROPERU', nombre: 'Petroperu'),
      CatalogoItem(codigo: 'SOLGAS', nombre: 'Solgas'),
    ];
  }

  @override
  Future<StockContinuarPreview> obtenerPreviewContinuar() async {
    return const StockContinuarPreview(puedeContinuar: false);
  }

  @override
  Future<StockResumen> continuarDeAyer() async {
    throw const ApiException(message: 'No implementado en fake.');
  }
}

class _FakeReportesService implements ReportesService {
  _FakeReportesService.empty()
    : _reporte = ReporteDiario(
        fecha: DateTime.parse('2026-01-16'),
        pedidosCount: 0,
        balonesVendidos: 0,
        montoTotalCentavos: 0,
        montoPagadoCentavos: 0,
        montoPendienteCentavos: 0,
        pedidos: const [],
      ),
      _deudas = const DeudasResumen(
        pedidosCount: 0,
        montoPendienteCentavos: 0,
        pedidos: [],
      ),
      _resumenError = null,
      _deudasError = null;

  _FakeReportesService.withData()
    : _reporte = ReporteDiario(
        fecha: DateTime.parse('2026-01-16'),
        pedidosCount: 2,
        balonesVendidos: 3,
        montoTotalCentavos: 16500,
        montoPagadoCentavos: 11000,
        montoPendienteCentavos: 5500,
        pedidos: [
          PedidoReporte(
            id: '1',
            clienteId: '1',
            clienteAlias: 'Las Higueras 371',
            cantidadBalones: 1,
            marcaBalon: 'PETROPERU',
            tipoBalon: 'NORMAL',
            precioUnitarioCentavos: 5500,
            montoTotalCentavos: 5500,
            montoPendienteCentavos: 5500,
            pagado: false,
            fechaEntrega: DateTime.parse('2026-01-16'),
            createdAt: DateTime.parse('2026-01-16T10:45:03.084894-05:00'),
          ),
        ],
      ),
      _deudas = DeudasResumen(
        pedidosCount: 1,
        montoPendienteCentavos: 5500,
        pedidos: [
          PedidoReporte(
            id: '1',
            clienteId: '1',
            clienteAlias: 'Las Higueras 371',
            cantidadBalones: 1,
            marcaBalon: 'PETROPERU',
            tipoBalon: 'NORMAL',
            precioUnitarioCentavos: 5500,
            montoTotalCentavos: 5500,
            montoPendienteCentavos: 5500,
            pagado: false,
            fechaEntrega: DateTime.parse('2026-01-16'),
            createdAt: DateTime.parse('2026-01-16T10:45:03.084894-05:00'),
          ),
        ],
      ),
      _resumenError = null,
      _deudasError = null;

  _FakeReportesService.withMixedOrders()
    : _reporte = ReporteDiario(
        fecha: DateTime.parse('2026-01-16'),
        pedidosCount: 2,
        balonesVendidos: 2,
        montoTotalCentavos: 11000,
        montoPagadoCentavos: 5500,
        montoPendienteCentavos: 5500,
        pedidos: [
          PedidoReporte(
            id: '1',
            clienteId: '1',
            clienteAlias: 'Pedido pagado',
            cantidadBalones: 1,
            marcaBalon: 'PETROPERU',
            tipoBalon: 'NORMAL',
            precioUnitarioCentavos: 5500,
            montoTotalCentavos: 5500,
            montoPendienteCentavos: 0,
            pagado: true,
            fechaEntrega: DateTime.parse('2026-01-16'),
            createdAt: DateTime.parse('2026-01-16T10:00:00-05:00'),
          ),
          PedidoReporte(
            id: '2',
            clienteId: '2',
            clienteAlias: 'Pedido pendiente',
            cantidadBalones: 1,
            marcaBalon: 'PETROPERU',
            tipoBalon: 'NORMAL',
            precioUnitarioCentavos: 5500,
            montoTotalCentavos: 5500,
            montoPendienteCentavos: 5500,
            pagado: false,
            fechaEntrega: DateTime.parse('2026-01-16'),
            createdAt: DateTime.parse('2026-01-16T11:00:00-05:00'),
          ),
        ],
      ),
      _deudas = const DeudasResumen(
        pedidosCount: 0,
        montoPendienteCentavos: 0,
        pedidos: [],
      ),
      _resumenError = null,
      _deudasError = null;

  _FakeReportesService.failure()
    : _reporte = null,
      _deudas = const DeudasResumen(
        pedidosCount: 0,
        montoPendienteCentavos: 0,
        pedidos: [],
      ),
      _resumenError = const ApiException(
        message: 'No se pudo cargar el resumen.',
      ),
      _deudasError = null;

  _FakeReportesService.deudasFailure()
    : _reporte = ReporteDiario(
        fecha: DateTime.parse('2026-01-16'),
        pedidosCount: 0,
        balonesVendidos: 0,
        montoTotalCentavos: 0,
        montoPagadoCentavos: 0,
        montoPendienteCentavos: 0,
        pedidos: const [],
      ),
      _deudas = null,
      _resumenError = null,
      _deudasError = const ApiException(
        message: 'No se pudo cargar las deudas.',
      );

  final ReporteDiario? _reporte;
  final DeudasResumen? _deudas;
  final ApiException? _resumenError;
  final ApiException? _deudasError;
  int summaryCalls = 0;
  int deudasCalls = 0;

  @override
  Future<ReporteDiario> obtenerResumenHoy() async {
    summaryCalls++;
    final error = _resumenError;
    if (error != null) {
      throw error;
    }
    return _reporte!;
  }

  @override
  Future<ReporteDiario> obtenerReporteDia(DateTime fecha) async {
    return obtenerResumenHoy();
  }

  @override
  Future<DeudasResumen> obtenerDeudas() async {
    deudasCalls++;
    final error = _deudasError;
    if (error != null) {
      throw error;
    }
    return _deudas!;
  }

  @override
  Future<ReporteSemanal> obtenerReporteSemana(DateTime desde) async {
    return ReporteSemanal(
      desde: desde,
      hasta: desde.add(const Duration(days: 6)),
      pedidosCount: 0,
      balonesVendidos: 0,
      balonesVendidos10kg: 0,
      balonesVendidos45kg: 0,
      montoTotalCentavos: 0,
      montoCobradoCentavos: 0,
      montoPendienteCentavos: 0,
      dias: const [],
    );
  }

  @override
  Future<ReporteMensual> obtenerReporteMes(DateTime mes) async {
    return ReporteMensual(
      mes:
          '${mes.year}-${mes.month.toString().padLeft(2, '0')}',
      pedidosCount: 0,
      balonesVendidos: 0,
      balonesVendidos10kg: 0,
      balonesVendidos45kg: 0,
      montoTotalCentavos: 0,
      montoCobradoCentavos: 0,
      montoPendienteCentavos: 0,
      dias: const [],
    );
  }
}
