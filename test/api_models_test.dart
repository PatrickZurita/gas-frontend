import 'package:flutter_test/flutter_test.dart';
import 'package:gas_frontend/features/clientes/models/cliente.dart';
import 'package:gas_frontend/features/clientes/models/cliente_create_request.dart';
import 'package:gas_frontend/features/clientes/models/cliente_reciente.dart';
import 'package:gas_frontend/features/pedidos/models/pedido.dart';
import 'package:gas_frontend/features/pedidos/models/pedido_create_request.dart';
import 'package:gas_frontend/features/reportes/models/deudas_resumen.dart';
import 'package:gas_frontend/features/reportes/models/pedido_reporte.dart';
import 'package:gas_frontend/features/reportes/models/reporte_diario.dart';
import 'package:gas_frontend/features/reportes/money_format.dart';
import 'package:gas_frontend/features/stock/models/catalogo_item.dart';
import 'package:gas_frontend/features/stock/models/stock_dia.dart';
import 'package:gas_frontend/features/stock/models/stock_requests.dart';
import 'package:gas_frontend/features/stock/models/stock_resumen.dart';

void main() {
  group('ID migration (int -> String)', () {
    test('Cliente normalizes int id from PostgreSQL to String', () {
      final cliente = Cliente.fromJson({
        'id': 123,
        'alias': 'Test',
        'telefono': '999999999',
      });
      expect(cliente.id, '123');
      expect(cliente.id, isA<String>());
    });

    test('Cliente accepts string UUID from DynamoDB', () {
      final cliente = Cliente.fromJson({
        'id': 'a1b2c3d4-e5f6-47g8-h9i0-j1k2l3m4n5o6',
        'alias': 'Test',
        'telefono': '999999999',
      });
      expect(cliente.id, 'a1b2c3d4-e5f6-47g8-h9i0-j1k2l3m4n5o6');
      expect(cliente.id, isA<String>());
    });

    test('Pedido normalizes int ids from PostgreSQL to String', () {
      final pedido = Pedido.fromJson({
        'id': 7,
        'cliente_id': 8,
        'direccion_id': 9,
        'created_at': '2026-01-16T10:00:00-05:00',
        'fecha_entrega': '2026-01-16',
        'cantidad_balones': 1,
        'total_soles': 55.0,
        'pagado': true,
        'saldo_pendiente': 0,
        'monto_total_centavos': 5500,
      });
      expect(pedido.id, '7');
      expect(pedido.clienteId, '8');
      expect(pedido.direccionId, '9');
    });

    test('Pedido accepts string UUID ids from DynamoDB', () {
      final pedido = Pedido.fromJson({
        'id': 'uuid-pedido',
        'cliente_id': 'uuid-cliente',
        'direccion_id': 'uuid-direccion',
        'created_at': '2026-01-16T10:00:00-05:00',
        'fecha_entrega': '2026-01-16',
        'cantidad_balones': 1,
        'total_soles': 55.0,
        'pagado': true,
        'saldo_pendiente': 0,
        'monto_total_centavos': 5500,
      });
      expect(pedido.id, 'uuid-pedido');
      expect(pedido.clienteId, 'uuid-cliente');
      expect(pedido.direccionId, 'uuid-direccion');
    });

    test('PedidoCreateRequest.toJson sends int for numeric clienteId', () {
      const request = PedidoCreateRequest(
        clienteId: '42',
        cantidadBalones: 1,
        pagado: true,
      );
      expect(request.toJson()['cliente_id'], 42);
      expect(request.toJson()['cliente_id'], isA<int>());
    });

    test('PedidoCreateRequest.toJson sends string for UUID clienteId', () {
      const request = PedidoCreateRequest(
        clienteId: 'uuid-cliente-xyz',
        cantidadBalones: 1,
        pagado: true,
      );
      expect(request.toJson()['cliente_id'], 'uuid-cliente-xyz');
      expect(request.toJson()['cliente_id'], isA<String>());
    });
  });

  group('Cliente', () {
    test('parses optional direccion when present', () {
      final cliente = Cliente.fromJson({
        'id': 4,
        'alias': 'Mandarinas 257',
        'telefono': '923777321',
        'direccion': 'Mandarinas 257',
      });

      expect(cliente.id, '4');
      expect(cliente.alias, 'Mandarinas 257');
      expect(cliente.telefono, '923777321');
      expect(cliente.direccion, 'Mandarinas 257');
    });

    test('allows missing direccion', () {
      final cliente = Cliente.fromJson({
        'id': 1,
        'alias': 'Las Higueras 371',
        'telefono': '999888777',
      });

      expect(cliente.direccion, isNull);
    });

    test('create request uses backend field names', () {
      const request = ClienteCreateRequest(
        alias: 'Mandarinas 257',
        telefono: '923777321',
      );

      expect(request.toJson(), {
        'alias': 'Mandarinas 257',
        'telefono': '923777321',
      });
    });

    test('parses recent client using integer cents', () {
      final cliente = ClienteReciente.fromJson({
        'id': 1,
        'alias': 'Las Higueras 371',
        'telefono': '999888777',
        'direccion': 'Las Higueras 371',
        'ultimo_pedido_fecha': '2026-01-16',
        'ultimo_total_centavos': 5500,
      });

      expect(cliente.id, '1');
      expect(cliente.direccion, 'Las Higueras 371');
      expect(cliente.ultimoPedidoFecha, DateTime.parse('2026-01-16'));
      expect(cliente.ultimoTotalCentavos, 5500);
      expect(cliente.toCliente().alias, 'Las Higueras 371');
    });
  });

  group('Pedido', () {
    test('parses money fields when backend returns strings', () {
      final pedido = Pedido.fromJson({
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
      });

      expect(pedido.id, '3');
      expect(pedido.clienteId, '2');
      expect(pedido.cantidadBalones, 1);
      expect(pedido.totalSoles, 55.00);
      expect(pedido.pagado, isTrue);
      expect(pedido.saldoPendiente, 0.00);
      expect(pedido.marcaBalon, 'PETROPERU');
      expect(pedido.tipoBalon, 'NORMAL');
      expect(pedido.precioUnitarioCentavos, 5500);
      expect(pedido.montoTotalCentavos, 5500);
      expect(pedido.montoPendienteCentavos, 0);
    });

    test('parses money fields when backend returns numbers', () {
      final pedido = Pedido.fromJson({
        'id': 3,
        'cliente_id': 2,
        'direccion_id': 2,
        'created_at': '2026-01-16T10:45:03.084894-05:00',
        'fecha_entrega': '2026-01-16',
        'cantidad_balones': 1,
        'total_soles': 55.0,
        'pagado': false,
        'saldo_pendiente': 55,
      });

      expect(pedido.totalSoles, 55.00);
      expect(pedido.saldoPendiente, 55.00);
    });

    test('create request uses backend field names', () {
      const request = PedidoCreateRequest(
        clienteId: '2',
        cantidadBalones: 1,
        pagado: true,
        marcaBalon: 'PETROPERU',
        tipoBalon: 'NORMAL',
        precioUnitarioCentavos: 5500,
        montoTotalCentavos: 5500,
        montoPendienteCentavos: 0,
      );

      expect(request.toJson(), {
        'cliente_id': 2,
        'cantidad_balones': 1,
        'pagado': true,
        'marca_balon': 'PETROPERU',
        'tipo_balon': 'NORMAL',
        'peso_balon_kg': 10,
        'precio_unitario_centavos': 5500,
        'monto_total_centavos': 5500,
        'monto_pendiente_centavos': 0,
      });
    });

    test('create request defaults peso_balon_kg to 10', () {
      const request = PedidoCreateRequest(
        clienteId: '2',
        cantidadBalones: 1,
        pagado: true,
      );

      expect(request.toJson()['peso_balon_kg'], 10);
    });

    test('create request serializes peso_balon_kg 45 when provided', () {
      const request = PedidoCreateRequest(
        clienteId: '2',
        cantidadBalones: 1,
        pagado: true,
        pesoBalonKg: 45,
      );

      expect(request.toJson()['peso_balon_kg'], 45);
    });
  });

  group('Pedido V2 fields', () {
    test('legacy payload defaults estado ACTIVO and peso 10', () {
      final pedido = Pedido.fromJson({
        'id': 1,
        'cliente_id': 1,
        'direccion_id': 1,
        'created_at': '2026-01-16T10:45:03.084894-05:00',
        'fecha_entrega': '2026-01-16',
        'cantidad_balones': 1,
        'total_soles': 55.0,
        'pagado': true,
        'saldo_pendiente': 0,
        'monto_total_centavos': 5500,
      });

      expect(pedido.pesoBalonKg, 10);
      expect(pedido.estado, PedidoEstado.activo);
      expect(pedido.esAnulado, isFalse);
      expect(pedido.anuladoAt, isNull);
      expect(pedido.anuladoMotivo, isNull);
    });

    test('parses estado ANULADO and motivo', () {
      final pedido = Pedido.fromJson({
        'id': 1,
        'cliente_id': 1,
        'direccion_id': 1,
        'created_at': '2026-01-16T10:45:03.084894-05:00',
        'fecha_entrega': '2026-01-16',
        'cantidad_balones': 1,
        'total_soles': 55.0,
        'pagado': true,
        'saldo_pendiente': 0,
        'estado': 'ANULADO',
        'anulado_at': '2026-01-16T12:00:00-05:00',
        'anulado_motivo': 'Duplicado',
        'peso_balon_kg': 45,
        'updated_at': '2026-01-16T12:00:00-05:00',
      });

      expect(pedido.esAnulado, isTrue);
      expect(pedido.anuladoMotivo, 'Duplicado');
      expect(pedido.pesoBalonKg, 45);
      expect(pedido.updatedAt, isNotNull);
    });
  });

  group('Stock', () {
    test('parses catalog item', () {
      final item = CatalogoItem.fromJson({
        'codigo': 'PETROPERU',
        'nombre': 'Petroperu',
      });

      expect(item.codigo, 'PETROPERU');
      expect(item.nombre, 'Petroperu');
    });

    test('parses stock summary with data', () {
      final stock = StockResumen.fromJson({
        'fecha': '2026-01-16',
        'stock_iniciado': true,
        'stock_inicial': 30,
        'entradas': 10,
        'salidas': 4,
        'ajustes': -1,
        'stock_actual': 35,
        'stock_final_fisico': null,
        'cerrado': false,
      });

      expect(stock.stockIniciado, isTrue);
      expect(stock.stockInicial, 30);
      expect(stock.stockActual, 35);
      expect(stock.ajustes, -1);
      expect(stock.compras, 10);
    });

    test('parses stock summary inicio and compras by weight', () {
      final stock = StockResumen.fromJson({
        'fecha': '2026-06-21',
        'stock_iniciado': true,
        'stock_inicial': 34,
        'compras': 0,
        'entradas': 0,
        'salidas': 0,
        'ajustes': 0,
        'stock_actual': 34,
        'stock_final_fisico': null,
        'cerrado': false,
        'por_peso': {
          '10kg': {
            'inicio': 32,
            'compras': 0,
            'salidas': 0,
            'reversas': 0,
            'ajustes': 0,
            'stock_disponible': 32,
          },
          '45kg': {
            'inicio': 2,
            'compras': 0,
            'salidas': 0,
            'reversas': 0,
            'ajustes': 0,
            'stock_disponible': 2,
          },
        },
      });

      expect(stock.compras, 0);
      expect(stock.porPeso?.inicio10kg, 32);
      expect(stock.porPeso?.inicio45kg, 2);
      expect(stock.porPeso?.compras10kg, 0);
      expect(stock.porPeso?.compras45kg, 0);
      expect(stock.porPeso?.stockActual10kg, 32);
      expect(stock.porPeso?.stockActual45kg, 2);
    });

    test('falls back to legacy entradas when compras is missing', () {
      final stock = StockResumen.fromJson({
        'fecha': '2026-06-21',
        'stock_iniciado': true,
        'stock_inicial': 30,
        'entradas': 3,
        'salidas': 1,
        'ajustes': 0,
        'stock_actual': 32,
        'stock_final_fisico': null,
        'cerrado': false,
        'por_peso': {
          '10kg': {
            'entradas': 2,
            'salidas': 1,
            'reversas': 0,
            'ajustes': 0,
            'stock_disponible': 31,
          },
          '45kg': {
            'entradas': 1,
            'salidas': 0,
            'reversas': 0,
            'ajustes': 0,
            'stock_disponible': 1,
          },
        },
      });

      expect(stock.compras, 3);
      expect(stock.porPeso?.inicio10kg, isNull);
      expect(stock.porPeso?.inicio45kg, isNull);
      expect(stock.porPeso?.compras10kg, 2);
      expect(stock.porPeso?.compras45kg, 1);
    });

    test('parses stock summary not started', () {
      final stock = StockResumen.fromJson({
        'fecha': '2026-01-16',
        'stock_iniciado': false,
        'stock_inicial': null,
        'entradas': 0,
        'salidas': 0,
        'ajustes': 0,
        'stock_actual': null,
        'stock_final_fisico': null,
        'cerrado': false,
      });

      expect(stock.stockIniciado, isFalse);
      expect(stock.stockActual, isNull);
    });

    test('parses stock day with movements', () {
      final stock = StockDia.fromJson({
        'fecha': '2026-01-16',
        'stock_iniciado': true,
        'stock_inicial': 30,
        'entradas': 0,
        'salidas': 1,
        'ajustes': 0,
        'stock_actual': 29,
        'stock_final_fisico': null,
        'cerrado': false,
        'movimientos': [
          {
            'id': 1,
            'tipo': 'SALIDA_PEDIDO',
            'cantidad_delta': -1,
            'stock_resultante': 29,
            'pedido_id': 10,
            'observacion': null,
            'created_at': '2026-01-16T10:45:03.084894-05:00',
          },
        ],
      });

      expect(stock.movimientos, hasLength(1));
      expect(stock.movimientos.single.cantidadDelta, -1);
    });

    test('stock requests use backend field names', () {
      expect(
        StockIniciarDiaRequest(
          fecha: DateTime(2026, 1, 16),
          stockInicial: 30,
        ).toJson(),
        {'fecha': '2026-01-16', 'stock_inicial': 30},
      );
      expect(
        StockEntradaRequest(
          fecha: DateTime(2026, 1, 16),
          cantidad: 10,
        ).toJson(),
        {'fecha': '2026-01-16', 'cantidad': 10},
      );
      expect(
        StockAjusteRequest(
          fecha: DateTime(2026, 1, 16),
          stockFisico: 25,
        ).toJson(),
        {'fecha': '2026-01-16', 'stock_fisico': 25},
      );
    });
  });

  group('Reportes', () {
    test('parses PedidoReporte using centavos fields', () {
      final pedido = PedidoReporte.fromJson({
        'id': 1,
        'cliente_id': 1,
        'cliente_alias': 'Las Higueras 371',
        'cantidad_balones': 2,
        'marca_balon': 'PETROPERU',
        'tipo_balon': 'NORMAL',
        'precio_unitario_centavos': 5500,
        'monto_total_centavos': 11000,
        'monto_pendiente_centavos': 0,
        'pagado': true,
        'fecha_entrega': '2026-01-16',
        'created_at': '2026-01-16T10:45:03.084894-05:00',
      });

      expect(pedido.id, '1');
      expect(pedido.clienteAlias, 'Las Higueras 371');
      expect(pedido.cantidadBalones, 2);
      expect(pedido.marcaBalon, 'PETROPERU');
      expect(pedido.tipoBalon, 'NORMAL');
      expect(pedido.precioUnitarioCentavos, 5500);
      expect(pedido.montoTotalCentavos, 11000);
      expect(pedido.montoPendienteCentavos, 0);
      expect(pedido.pagado, isTrue);
      expect(pedido.fechaEntrega, DateTime.parse('2026-01-16'));
    });

    test('parses ReporteDiario with pedidos and integer money', () {
      final reporte = ReporteDiario.fromJson({
        'fecha': '2026-01-16',
        'pedidos_count': 2,
        'balones_vendidos': 3,
        'monto_total_centavos': 16500,
        'monto_pagado_centavos': 11000,
        'monto_pendiente_centavos': 5500,
        'pedidos': [
          {
            'id': 1,
            'cliente_id': 1,
            'cliente_alias': 'Las Higueras 371',
            'cantidad_balones': 2,
            'monto_total_centavos': 11000,
            'monto_pendiente_centavos': 0,
            'pagado': true,
            'fecha_entrega': '2026-01-16',
            'created_at': '2026-01-16T10:45:03.084894-05:00',
          },
        ],
      });

      expect(reporte.fecha, DateTime.parse('2026-01-16'));
      expect(reporte.pedidosCount, 2);
      expect(reporte.balonesVendidos, 3);
      expect(reporte.montoTotalCentavos, 16500);
      expect(reporte.montoPagadoCentavos, 11000);
      expect(reporte.montoPendienteCentavos, 5500);
      expect(reporte.pedidos, hasLength(1));
      expect(reporte.isEmpty, isFalse);
    });

    test('keeps daily summary totals in centavos without extra conversion', () {
      final pedidos = List.generate(
        6,
        (index) => {
          'id': index + 1,
          'cliente_id': index + 1,
          'cliente_alias': 'Cliente ${index + 1}',
          'cantidad_balones': 1,
          'marca_balon': 'PETROPERU',
          'tipo_balon': 'NORMAL',
          'precio_unitario_centavos': 5500,
          'monto_total_centavos': 5500,
          'monto_pendiente_centavos': index < 3 ? 0 : 5500,
          'pagado': index < 3,
          'fecha_entrega': '2026-01-16',
          'created_at': '2026-01-16T10:45:03.084894-05:00',
        },
      );

      final reporte = ReporteDiario.fromJson({
        'fecha': '2026-01-16',
        'pedidos_count': 6,
        'balones_vendidos': 6,
        'monto_total_centavos': 33000,
        'monto_pagado_centavos': 16500,
        'monto_pendiente_centavos': 16500,
        'pedidos': pedidos,
      });

      expect(reporte.pedidosCount, 6);
      expect(reporte.balonesVendidos, 6);
      expect(reporte.montoTotalCentavos, 33000);
      expect(
        reporte.montoPagadoCentavos + reporte.montoPendienteCentavos,
        reporte.montoTotalCentavos,
      );
      expect(formatSolesFromCentavos(reporte.montoTotalCentavos), 'S/ 330.00');
    });

    test('parses empty ReporteDiario', () {
      final reporte = ReporteDiario.fromJson({
        'fecha': '2026-01-16',
        'pedidos_count': 0,
        'balones_vendidos': 0,
        'monto_total_centavos': 0,
        'monto_pagado_centavos': 0,
        'monto_pendiente_centavos': 0,
        'pedidos': <Object?>[],
      });

      expect(reporte.isEmpty, isTrue);
      expect(reporte.montoTotalCentavos, 0);
      expect(reporte.pedidos, isEmpty);
    });

    test('parses DeudasResumen', () {
      final deudas = DeudasResumen.fromJson({
        'pedidos_count': 1,
        'monto_pendiente_centavos': 5500,
        'pedidos': [
          {
            'id': 2,
            'cliente_id': 1,
            'cliente_alias': 'Las Higueras 371',
            'cantidad_balones': 1,
            'monto_total_centavos': 5500,
            'monto_pendiente_centavos': 5500,
            'pagado': false,
            'fecha_entrega': '2026-01-16',
            'created_at': '2026-01-16T10:45:03.084894-05:00',
          },
        ],
      });

      expect(deudas.pedidosCount, 1);
      expect(deudas.montoPendienteCentavos, 5500);
      expect(deudas.pedidos.single.pagado, isFalse);
    });
  });

  group('formatSolesFromCentavos', () {
    test('formats integer centavos as soles text', () {
      expect(formatSolesFromCentavos(0), 'S/ 0.00');
      expect(formatSolesFromCentavos(5500), 'S/ 55.00');
      expect(formatSolesFromCentavos(110050), 'S/ 1,100.50');
    });
  });
}
