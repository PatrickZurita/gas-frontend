import '../../core/network/api_client.dart';
import 'models/demanda_perdida.dart';
import 'models/demanda_perdida_create_request.dart';

abstract interface class DemandaPerdidaService {
  Future<DemandaPerdida> registrarDemandaPerdida(
    DemandaPerdidaCreateRequest request,
  );
}

class ApiDemandaPerdidaService implements DemandaPerdidaService {
  const ApiDemandaPerdidaService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<DemandaPerdida> registrarDemandaPerdida(
    DemandaPerdidaCreateRequest request,
  ) async {
    final json = await _apiClient.postJson(
      '/demanda-perdida',
      body: request.toJson(),
    );
    return DemandaPerdida.fromJson(json as Map<String, Object?>);
  }
}
