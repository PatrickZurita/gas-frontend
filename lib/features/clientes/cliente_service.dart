import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import 'models/cliente.dart';
import 'models/cliente_create_request.dart';

class ClienteDuplicadoException extends ApiException {
  const ClienteDuplicadoException({required super.message, super.body})
    : super(statusCode: 409);
}

abstract interface class ClienteService {
  Future<Cliente> crearCliente(ClienteCreateRequest request);

  Future<List<Cliente>> buscarClientes(String query, {int limit = 10});

  Future<Cliente> obtenerCliente(int id);
}

class ApiClienteService implements ClienteService {
  const ApiClienteService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Cliente> crearCliente(ClienteCreateRequest request) async {
    try {
      final json = await _apiClient.postJson(
        '/clientes/',
        body: request.toJson(),
      );
      return Cliente.fromJson(json as Map<String, Object?>);
    } on ApiException catch (error) {
      if (error.statusCode == 409) {
        throw ClienteDuplicadoException(
          message: error.message,
          body: error.body,
        );
      }
      rethrow;
    }
  }

  @override
  Future<List<Cliente>> buscarClientes(String query, {int limit = 10}) async {
    final json = await _apiClient.getJson(
      '/clientes/search',
      queryParameters: {'q': query, 'limit': '$limit'},
    );

    final list = json as List<Object?>;
    return list
        .map((item) => Cliente.fromJson(item as Map<String, Object?>))
        .toList();
  }

  @override
  Future<Cliente> obtenerCliente(int id) async {
    final json = await _apiClient.getJson('/clientes/$id');
    return Cliente.fromJson(json as Map<String, Object?>);
  }
}
