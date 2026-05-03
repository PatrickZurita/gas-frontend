import 'package:flutter_test/flutter_test.dart';
import 'package:gas_frontend/features/clientes/models/cliente.dart';
import 'package:gas_frontend/features/clientes/models/cliente_create_request.dart';
import 'package:gas_frontend/features/pedidos/models/pedido.dart';
import 'package:gas_frontend/features/pedidos/models/pedido_create_request.dart';

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
        'pagado': true,
        'saldo_pendiente': '0.00',
      });

      expect(pedido.id, 3);
      expect(pedido.clienteId, 2);
      expect(pedido.cantidadBalones, 1);
      expect(pedido.totalSoles, 55.00);
      expect(pedido.pagado, isTrue);
      expect(pedido.saldoPendiente, 0.00);
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
        totalSoles: 55.00,
        pagado: true,
      );

      expect(request.toJson(), {
        'cliente_id': 2,
        'cantidad_balones': 1,
        'total_soles': 55.00,
        'pagado': true,
      });
    });
  });
}
