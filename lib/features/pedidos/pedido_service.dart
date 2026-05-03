import '../../core/network/api_client.dart';
import 'models/pedido.dart';
import 'models/pedido_create_request.dart';

abstract interface class PedidoService {
  Future<Pedido> crearPedido(PedidoCreateRequest request);

  Future<List<Pedido>> listarPedidosPorCliente(int clienteId);
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
  Future<List<Pedido>> listarPedidosPorCliente(int clienteId) async {
    final json = await _apiClient.getJson(
      '/pedidos',
      queryParameters: {'cliente_id': '$clienteId'},
    );

    final list = json as List<Object?>;
    return list
        .map((item) => Pedido.fromJson(item as Map<String, Object?>))
        .toList();
  }
}
