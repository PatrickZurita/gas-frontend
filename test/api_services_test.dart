import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gas_frontend/core/network/api_client.dart';
import 'package:gas_frontend/features/clientes/cliente_service.dart';
import 'package:gas_frontend/features/clientes/models/cliente_create_request.dart';
import 'package:gas_frontend/features/pedidos/models/pedido_create_request.dart';
import 'package:gas_frontend/features/pedidos/pedido_service.dart';
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
                'pagado': true,
                'saldo_pendiente': '0.00',
              }),
              201,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );

      final pedido = await service.crearPedido(
        const PedidoCreateRequest(
          clienteId: 2,
          cantidadBalones: 1,
          totalSoles: 55.00,
          pagado: true,
        ),
      );

      expect(capturedRequest.method, 'POST');
      expect(capturedRequest.url.path, '/pedidos');
      expect(pedido.totalSoles, 55.00);
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
                  'pagado': true,
                  'saldo_pendiente': '0.00',
                },
              ]),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );

      final pedidos = await service.listarPedidosPorCliente(1);

      expect(capturedRequest.method, 'GET');
      expect(capturedRequest.url.path, '/pedidos');
      expect(capturedRequest.url.queryParameters['cliente_id'], '1');
      expect(pedidos, hasLength(1));
      expect(pedidos.single.totalSoles, 110.00);
    });
  });
}
