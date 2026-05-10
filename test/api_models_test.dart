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
  group('Cliente', () {
    test('parses optional direccion when present', () {
      final cliente = Cliente.fromJson({
        'id': 4,
        'alias': 'Mandarinas 257',
        'telefono': '923777321',
        'direccion': 'Mandarinas 257',
      });

      expect(cliente.id, 4);
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

      expect(cliente.id, 1);
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

      expect(pedido.id, 3);
      expect(pedido.clienteId, 2);
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
        clienteId: 2,
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
        'precio_unitario_centavos': 5500,
        'monto_total_centavos': 5500,
        'monto_pendiente_centavos': 0,
      });
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
        'monto_total_centavos': 11000,
        'monto_pendiente_centavos': 0,
        'pagado': true,
        'fecha_entrega': '2026-01-16',
        'created_at': '2026-01-16T10:45:03.084894-05:00',
      });

      expect(pedido.id, 1);
      expect(pedido.clienteAlias, 'Las Higueras 371');
      expect(pedido.cantidadBalones, 2);
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
