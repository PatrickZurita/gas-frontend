import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import 'models/pedido.dart';
import 'models/pedido_create_request.dart';
import 'models/pedido_update_request.dart';

class PedidoConflictoException extends ApiException {
  const PedidoConflictoException({required super.message, super.body})
    : super(statusCode: 409);
}

abstract interface class PedidoService {
  Future<Pedido> crearPedido(PedidoCreateRequest request);

  Future<List<Pedido>> listarPedidosPorCliente(String clienteId);

  Future<Pedido> anularPedido(String pedidoId, {String? motivo});

  Future<Pedido> editarPedido(String pedidoId, PedidoUpdateRequest request);
}

class ApiPedidoService implements PedidoService {
  const ApiPedidoService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Pedido> crearPedido(PedidoCreateRequest request) async {
    final json = await _apiClient.postJson('/pedidos', body: request.toJson());
    return Pedido.fromJson(json as Map<String, Object?>);
  }

  @override
  Future<List<Pedido>> listarPedidosPorCliente(String clienteId) async {
    final json = await _apiClient.getJson(
      '/pedidos',
      queryParameters: {'cliente_id': clienteId},
    );

    final list = json as List<Object?>;
    return list
        .map((item) => Pedido.fromJson(item as Map<String, Object?>))
        .toList();
  }

  @override
  Future<Pedido> anularPedido(String pedidoId, {String? motivo}) async {
    try {
      final json = await _apiClient.postJson(
        '/pedidos/$pedidoId/anular',
        body: <String, Object?>{
          if (motivo != null && motivo.trim().isNotEmpty) 'motivo': motivo.trim(),
        },
      );
      return Pedido.fromJson(json as Map<String, Object?>);
    } on ApiException catch (error) {
      if (error.statusCode == 409) {
        throw PedidoConflictoException(
          message:
              error.message.isNotEmpty
                  ? error.message
                  : 'Este pedido ya esta anulado.',
          body: error.body,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Pedido> editarPedido(
    String pedidoId,
    PedidoUpdateRequest request,
  ) async {
    try {
      final json = await _apiClient.patchJson(
        '/pedidos/$pedidoId',
        body: request.toJson(),
      );
      return Pedido.fromJson(json as Map<String, Object?>);
    } on ApiException catch (error) {
      if (error.statusCode == 409) {
        throw PedidoConflictoException(
          message:
              error.message.isNotEmpty
                  ? error.message
                  : 'No se puede editar un pedido anulado.',
          body: error.body,
        );
      }
      rethrow;
    }
  }
}
