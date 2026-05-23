import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gas_frontend/core/network/api_client.dart';
import 'package:gas_frontend/features/clientes/cliente_service.dart';
import 'package:gas_frontend/features/clientes/models/cliente_create_request.dart';
import 'package:gas_frontend/features/pedidos/models/pedido_create_request.dart';
import 'package:gas_frontend/features/pedidos/models/pedido_update_request.dart';
import 'package:gas_frontend/features/pedidos/pedido_service.dart';
import 'package:gas_frontend/features/reportes/services/reportes_service.dart';
import 'package:gas_frontend/features/stock/models/stock_requests.dart';
import 'package:gas_frontend/features/stock/services/stock_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ClienteService', () {
    test('creates client using /clientes/ with trailing slash', () async {
      late http.Request capturedRequest;
      final service = ApiClienteService(
        ApiClient(
          baseUrl: 'http://example.test',
          httpClient: MockClient((request) async {
            capturedRequest = request;
            return http.Response(
              jsonEncode({
                'id': 4,
                'alias': 'Mandarinas 257',
                'telefono': '923777321',
                'direccion': 'Mandarinas 257',
              }),
              201,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );

      final cliente = await service.crearCliente(
        const ClienteCreateRequest(
          alias: 'Mandarinas 257',
          telefono: '923777321',
        ),
      );

      expect(capturedRequest.method, 'POST');
      expect(capturedRequest.url.path, '/clientes/');
      expect(capturedRequest.headers['content-type'], 'application/json');
      expect(cliente.direccion, 'Mandarinas 257');
    });

    test('maps 409 duplicate client to domain exception', () async {
      final service = ApiClienteService(
        ApiClient(
          baseUrl: 'http://example.test',
          httpClient: MockClient((request) async {
            return http.Response(
              jsonEncode({'detail': 'Ya existe un cliente con ese alias.'}),
              409,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );

      expect(
        () => service.crearCliente(
          const ClienteCreateRequest(
            alias: 'Mandarinas 257',
            telefono: '923777321',
          ),
        ),
        throwsA(isA<ClienteDuplicadoException>()),
      );
    });

    test('lists clients from /clientes with query and pagination', () async {
      late http.Request capturedRequest;
      final service = ApiClienteService(
        ApiClient(
          baseUrl: 'http://example.test',
          httpClient: MockClient((request) async {
            capturedRequest = request;
            return http.Response(
              jsonEncode([
                {
                  'id': 1,
                  'alias': 'Las Higueras 371',
                  'telefono': '999888777',
                  'direccion': 'Las Higueras 371',
                },
              ]),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );

      final clientes =
          await service.listarClientes(query: 'las', limit: 50, offset: 10);

      expect(capturedRequest.method, 'GET');
      expect(capturedRequest.url.path, '/clientes');
      expect(capturedRequest.url.queryParameters['q'], 'las');
      expect(capturedRequest.url.queryParameters['limit'], '50');
      expect(capturedRequest.url.queryParameters['offset'], '10');
      expect(clientes.single.alias, 'Las Higueras 371');
    });

    test('gets recent clients from /clientes/recientes', () async {
      late http.Request capturedRequest;
      final service = ApiClienteService(
        ApiClient(
          baseUrl: 'http://example.test',
          httpClient: MockClient((request) async {
            capturedRequest = request;
            return http.Response(
              jsonEncode([
                {
                  'id': 1,
                  'alias': 'Las Higueras 371',
                  'telefono': '999888777',
                  'direccion': 'Las Higueras 371',
                  'ultimo_pedido_fecha': '2026-01-16',
                  'ultimo_total_centavos': 5500,
                },
              ]),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );

      final recientes = await service.obtenerClientesRecientes(limit: 5);

      expect(capturedRequest.method, 'GET');
      expect(capturedRequest.url.path, '/clientes/recientes');
      expect(capturedRequest.url.queryParameters['limit'], '5');
      expect(recientes.single.alias, 'Las Higueras 371');
      expect(recientes.single.ultimoTotalCentavos, 5500);
    });
  });

  group('PedidoService', () {
    test('creates order using /pedidos without trailing slash', () async {
      late http.Request capturedRequest;
      final service = ApiPedidoService(
        ApiClient(
          baseUrl: 'http://example.test',
          httpClient: MockClient((request) async {
            capturedRequest = request;
            return http.Response(
              jsonEncode({
                'id': 3,
                'cliente_id': 2,
                'direccion_id': 2,
                'created_at': '2026-01-16T10:45:03.084894-05:00',
                'fecha_entrega': '2026-01-16',
                'cantidad_balones': 1,
                'total_soles': '55.00',
                'marca_balon': 'PETROPERU',
                'tipo_balon': 'NORMAL',
                'precio_unitario_centavos': 5500,
                'monto_total_centavos': 5500,
                'pagado': true,
                'saldo_pendiente': '0.00',
                'monto_pendiente_centavos': 0,
              }),
              201,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );

      final pedido = await service.crearPedido(
        const PedidoCreateRequest(
          clienteId: '2',
          cantidadBalones: 1,
          pagado: true,
          marcaBalon: 'PETROPERU',
          tipoBalon: 'NORMAL',
          precioUnitarioCentavos: 5500,
          montoTotalCentavos: 5500,
          montoPendienteCentavos: 0,
        ),
      );

      expect(capturedRequest.method, 'POST');
      expect(capturedRequest.url.path, '/pedidos');
      final body = jsonDecode(capturedRequest.body) as Map<String, Object?>;
      expect(body['marca_balon'], 'PETROPERU');
      expect(body['tipo_balon'], 'NORMAL');
      expect(body['peso_balon_kg'], 10);
      expect(body['precio_unitario_centavos'], 5500);
      expect(body['monto_total_centavos'], 5500);
      expect(body['monto_pendiente_centavos'], 0);
      expect(pedido.totalSoles, 55.00);
    });

    test('anular pedido posts to /pedidos/{id}/anular with motivo', () async {
      late http.Request capturedRequest;
      final service = ApiPedidoService(
        ApiClient(
          baseUrl: 'http://example.test',
          httpClient: MockClient((request) async {
            capturedRequest = request;
            return http.Response(
              jsonEncode(_pedidoAnuladoJson()),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );

      final pedido = await service.anularPedido('10', motivo: 'Duplicado');

      expect(capturedRequest.method, 'POST');
      expect(capturedRequest.url.path, '/pedidos/10/anular');
      final body = jsonDecode(capturedRequest.body) as Map<String, Object?>;
      expect(body['motivo'], 'Duplicado');
      expect(pedido.esAnulado, isTrue);
    });

    test('anular pedido maps 409 to PedidoConflictoException', () {
      final service = ApiPedidoService(
        ApiClient(
          baseUrl: 'http://example.test',
          httpClient: MockClient((request) async {
            return http.Response(
              jsonEncode({'detail': 'Este pedido ya esta anulado.'}),
              409,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );

      expect(
        () => service.anularPedido('10'),
        throwsA(isA<PedidoConflictoException>()),
      );
    });

    test('editar pedido patches /pedidos/{id} with new fields', () async {
      late http.Request capturedRequest;
      final service = ApiPedidoService(
        ApiClient(
          baseUrl: 'http://example.test',
          httpClient: MockClient((request) async {
            capturedRequest = request;
            return http.Response(
              jsonEncode({
                'id': 10,
                'cliente_id': 1,
                'direccion_id': 1,
                'created_at': '2026-01-16T10:00:00-05:00',
                'fecha_entrega': '2026-01-16',
                'cantidad_balones': 2,
                'total_soles': '110.00',
                'pagado': false,
                'saldo_pendiente': '110.00',
                'marca_balon': 'PETROPERU',
                'tipo_balon': 'NORMAL',
                'precio_unitario_centavos': 5500,
                'monto_total_centavos': 11000,
                'monto_pendiente_centavos': 11000,
                'peso_balon_kg': 45,
                'estado': 'ACTIVO',
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );

      final pedido = await service.editarPedido(
        '10',
        const PedidoUpdateRequest(
          cantidadBalones: 2,
          pesoBalonKg: 45,
          motivoEdicion: 'Correccion del pedido',
        ),
      );

      expect(capturedRequest.method, 'PATCH');
      expect(capturedRequest.url.path, '/pedidos/10');
      final body = jsonDecode(capturedRequest.body) as Map<String, Object?>;
      expect(body['cantidad_balones'], 2);
      expect(body['peso_balon_kg'], 45);
      expect(body['motivo_edicion'], 'Correccion del pedido');
      expect(pedido.pesoBalonKg, 45);
    });

    test('editar pedido maps 409 to PedidoConflictoException', () {
      final service = ApiPedidoService(
        ApiClient(
          baseUrl: 'http://example.test',
          httpClient: MockClient((request) async {
            return http.Response(
              jsonEncode({'detail': 'No se puede editar un pedido anulado.'}),
              409,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );

      expect(
        () => service.editarPedido(
          '10',
          const PedidoUpdateRequest(cantidadBalones: 2),
        ),
        throwsA(isA<PedidoConflictoException>()),
      );
    });

    test('lists orders by cliente_id query parameter', () async {
      late http.Request capturedRequest;
      final service = ApiPedidoService(
        ApiClient(
          baseUrl: 'http://example.test',
          httpClient: MockClient((request) async {
            capturedRequest = request;
            return http.Response(
              jsonEncode([
                {
                  'id': 2,
                  'cliente_id': 1,
                  'direccion_id': 1,
                  'created_at': '2026-01-16T10:33:46.613608-05:00',
                  'fecha_entrega': '2026-01-16',
                  'cantidad_balones': 2,
                  'total_soles': '110.00',
                  'marca_balon': 'SOLGAS',
                  'tipo_balon': 'PREMIUM',
                  'precio_unitario_centavos': 5500,
                  'monto_total_centavos': 11000,
                  'pagado': true,
                  'saldo_pendiente': '0.00',
                  'monto_pendiente_centavos': 0,
                },
              ]),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );

      final pedidos = await service.listarPedidosPorCliente('1');

      expect(capturedRequest.method, 'GET');
      expect(capturedRequest.url.path, '/pedidos');
      expect(capturedRequest.url.queryParameters['cliente_id'], '1');
      expect(pedidos, hasLength(1));
      expect(pedidos.single.totalSoles, 110.00);
    });
  });

  group('ReportesService', () {
    test('gets today summary from /reportes/resumen-hoy', () async {
      late http.Request capturedRequest;
      final service = ApiReportesService(
        ApiClient(
          baseUrl: 'http://example.test',
          httpClient: MockClient((request) async {
            capturedRequest = request;
            return http.Response(
              jsonEncode(_reporteJson()),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );

      final reporte = await service.obtenerResumenHoy();

      expect(capturedRequest.method, 'GET');
      expect(capturedRequest.url.path, '/reportes/resumen-hoy');
      expect(reporte.montoTotalCentavos, 16500);
      expect(reporte.pedidos.single.montoPendienteCentavos, 5500);
    });

    test('gets day report using fecha query parameter', () async {
      late http.Request capturedRequest;
      final service = ApiReportesService(
        ApiClient(
          baseUrl: 'http://example.test',
          httpClient: MockClient((request) async {
            capturedRequest = request;
            return http.Response(
              jsonEncode(_reporteJson()),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );

      await service.obtenerReporteDia(DateTime(2026, 1, 16));

      expect(capturedRequest.method, 'GET');
      expect(capturedRequest.url.path, '/reportes/dia');
      expect(capturedRequest.url.queryParameters['fecha'], '2026-01-16');
    });

    test('gets weekly report from /reportes/semana', () async {
      late http.Request capturedRequest;
      final service = ApiReportesService(
        ApiClient(
          baseUrl: 'http://example.test',
          httpClient: MockClient((request) async {
            capturedRequest = request;
            return http.Response(
              jsonEncode({
                'desde': '2026-05-18',
                'hasta': '2026-05-24',
                'pedidos_count': 12,
                'balones_vendidos': 14,
                'balones_vendidos_10kg': 12,
                'balones_vendidos_45kg': 2,
                'monto_total_centavos': 81000,
                'monto_cobrado_centavos': 76000,
                'monto_pendiente_centavos': 5000,
                'dias': <Map<String, Object?>>[],
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );

      final reporte =
          await service.obtenerReporteSemana(DateTime(2026, 5, 18));

      expect(capturedRequest.method, 'GET');
      expect(capturedRequest.url.path, '/reportes/semana');
      expect(capturedRequest.url.queryParameters['desde'], '2026-05-18');
      expect(reporte.balonesVendidos10kg, 12);
      expect(reporte.balonesVendidos45kg, 2);
    });

    test('gets monthly report from /reportes/mes', () async {
      late http.Request capturedRequest;
      final service = ApiReportesService(
        ApiClient(
          baseUrl: 'http://example.test',
          httpClient: MockClient((request) async {
            capturedRequest = request;
            return http.Response(
              jsonEncode({
                'mes': '2026-05',
                'pedidos_count': 50,
                'balones_vendidos': 60,
                'balones_vendidos_10kg': 55,
                'balones_vendidos_45kg': 5,
                'monto_total_centavos': 330000,
                'monto_cobrado_centavos': 310000,
                'monto_pendiente_centavos': 20000,
                'dias': <Map<String, Object?>>[],
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );

      final reporte = await service.obtenerReporteMes(DateTime(2026, 5));

      expect(capturedRequest.method, 'GET');
      expect(capturedRequest.url.path, '/reportes/mes');
      expect(capturedRequest.url.queryParameters['mes'], '2026-05');
      expect(reporte.mes, '2026-05');
      expect(reporte.balonesVendidos45kg, 5);
    });

    test('gets debts summary from /reportes/deudas', () async {
      late http.Request capturedRequest;
      final service = ApiReportesService(
        ApiClient(
          baseUrl: 'http://example.test',
          httpClient: MockClient((request) async {
            capturedRequest = request;
            return http.Response(
              jsonEncode({
                'pedidos_count': 1,
                'monto_pendiente_centavos': 5500,
                'pedidos': [_pedidoReporteJson()],
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );

      final deudas = await service.obtenerDeudas();

      expect(capturedRequest.method, 'GET');
      expect(capturedRequest.url.path, '/reportes/deudas');
      expect(deudas.montoPendienteCentavos, 5500);
    });
  });

  group('StockService', () {
    test('gets today stock summary from /stock/resumen-hoy', () async {
      late http.Request capturedRequest;
      final service = ApiStockService(
        ApiClient(
          baseUrl: 'http://example.test',
          httpClient: MockClient((request) async {
            capturedRequest = request;
            return http.Response(
              jsonEncode(_stockResumenJson()),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );

      final stock = await service.obtenerResumenHoy();

      expect(capturedRequest.method, 'GET');
      expect(capturedRequest.url.path, '/stock/resumen-hoy');
      expect(stock.stockActual, 29);
    });

    test('gets stock day using fecha query parameter', () async {
      late http.Request capturedRequest;
      final service = ApiStockService(
        ApiClient(
          baseUrl: 'http://example.test',
          httpClient: MockClient((request) async {
            capturedRequest = request;
            return http.Response(
              jsonEncode({
                ..._stockResumenJson(),
                'movimientos': [_movimientoStockJson()],
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );

      final stock = await service.obtenerStockDia(DateTime(2026, 1, 16));

      expect(capturedRequest.method, 'GET');
      expect(capturedRequest.url.path, '/stock/dia');
      expect(capturedRequest.url.queryParameters['fecha'], '2026-01-16');
      expect(stock.movimientos, hasLength(1));
    });

    test('starts stock day with /stock/iniciar-dia', () async {
      late http.Request capturedRequest;
      final service = ApiStockService(
        ApiClient(
          baseUrl: 'http://example.test',
          httpClient: MockClient((request) async {
            capturedRequest = request;
            return http.Response(
              jsonEncode(_stockOperacionJson('INICIO_DIA', 30, 30)),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );

      await service.iniciarDia(
        StockIniciarDiaRequest(fecha: DateTime(2026, 1, 16), stockInicial: 30),
      );

      expect(capturedRequest.method, 'POST');
      expect(capturedRequest.url.path, '/stock/iniciar-dia');
    });

    test('registers stock entry with /stock/entrada', () async {
      late http.Request capturedRequest;
      final service = ApiStockService(
        ApiClient(
          baseUrl: 'http://example.test',
          httpClient: MockClient((request) async {
            capturedRequest = request;
            return http.Response(
              jsonEncode(_stockOperacionJson('ENTRADA', 10, 40)),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );

      await service.registrarEntrada(
        StockEntradaRequest(fecha: DateTime(2026, 1, 16), cantidad: 10),
      );

      expect(capturedRequest.method, 'POST');
      expect(capturedRequest.url.path, '/stock/entrada');
    });

    test('adjusts stock with /stock/ajuste', () async {
      late http.Request capturedRequest;
      final service = ApiStockService(
        ApiClient(
          baseUrl: 'http://example.test',
          httpClient: MockClient((request) async {
            capturedRequest = request;
            return http.Response(
              jsonEncode(_stockOperacionJson('AJUSTE', -2, 28)),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );

      await service.ajustarStock(
        StockAjusteRequest(fecha: DateTime(2026, 1, 16), stockFisico: 28),
      );

      expect(capturedRequest.method, 'POST');
      expect(capturedRequest.url.path, '/stock/ajuste');
    });

    test('gets product catalogs', () async {
      final paths = <String>[];
      final service = ApiStockService(
        ApiClient(
          baseUrl: 'http://example.test',
          httpClient: MockClient((request) async {
            paths.add(request.url.path);
            return http.Response(
              jsonEncode({
                'items': [
                  {'codigo': 'NORMAL', 'nombre': 'Normal'},
                ],
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );

      final tipos = await service.obtenerTiposBalon();
      final marcas = await service.obtenerMarcasBalon();

      expect(paths, ['/catalogos/tipos-balon', '/catalogos/marcas-balon']);
      expect(tipos.single.codigo, 'NORMAL');
      expect(marcas.single.nombre, 'Normal');
    });
  });
}

Map<String, Object?> _reporteJson() {
  return {
    'fecha': '2026-01-16',
    'pedidos_count': 2,
    'balones_vendidos': 3,
    'monto_total_centavos': 16500,
    'monto_pagado_centavos': 11000,
    'monto_pendiente_centavos': 5500,
    'pedidos': [_pedidoReporteJson()],
  };
}

Map<String, Object?> _pedidoReporteJson() {
  return {
    'id': 1,
    'cliente_id': 1,
    'cliente_alias': 'Las Higueras 371',
    'cantidad_balones': 1,
    'marca_balon': 'PETROPERU',
    'tipo_balon': 'NORMAL',
    'precio_unitario_centavos': 5500,
    'monto_total_centavos': 5500,
    'monto_pendiente_centavos': 5500,
    'pagado': false,
    'fecha_entrega': '2026-01-16',
    'created_at': '2026-01-16T10:45:03.084894-05:00',
  };
}

Map<String, Object?> _stockResumenJson() {
  return {
    'fecha': '2026-01-16',
    'stock_iniciado': true,
    'stock_inicial': 30,
    'entradas': 0,
    'salidas': 1,
    'ajustes': 0,
    'stock_actual': 29,
    'stock_final_fisico': null,
    'cerrado': false,
  };
}

Map<String, Object?> _movimientoStockJson() {
  return {
    'id': 1,
    'tipo': 'SALIDA_PEDIDO',
    'cantidad_delta': -1,
    'stock_resultante': 29,
    'pedido_id': 3,
    'observacion': null,
    'created_at': '2026-01-16T10:45:03.084894-05:00',
  };
}

Map<String, Object?> _stockOperacionJson(
  String tipo,
  int cantidadDelta,
  int stockActual,
) {
  return {
    'fecha': '2026-01-16',
    'tipo': tipo,
    'cantidad_delta': cantidadDelta,
    'stock_actual': stockActual,
    'observacion': null,
  };
}

Map<String, Object?> _pedidoAnuladoJson() {
  return {
    'id': 10,
    'cliente_id': 1,
    'direccion_id': 1,
    'created_at': '2026-01-16T10:00:00-05:00',
    'fecha_entrega': '2026-01-16',
    'cantidad_balones': 1,
    'total_soles': '55.00',
    'pagado': true,
    'saldo_pendiente': '0.00',
    'marca_balon': 'PETROPERU',
    'tipo_balon': 'NORMAL',
    'precio_unitario_centavos': 5500,
    'monto_total_centavos': 5500,
    'monto_pendiente_centavos': 0,
    'peso_balon_kg': 10,
    'estado': 'ANULADO',
    'anulado_at': '2026-01-16T11:00:00-05:00',
    'anulado_motivo': 'Duplicado',
  };
}
