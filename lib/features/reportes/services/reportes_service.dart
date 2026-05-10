import '../../../core/network/api_client.dart';
import '../models/deudas_resumen.dart';
import '../models/reporte_diario.dart';

abstract interface class ReportesService {
  Future<ReporteDiario> obtenerResumenHoy();

  Future<ReporteDiario> obtenerReporteDia(DateTime fecha);

  Future<DeudasResumen> obtenerDeudas();
}

class ApiReportesService implements ReportesService {
  const ApiReportesService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ReporteDiario> obtenerResumenHoy() async {
    final json = await _apiClient.getJson('/reportes/resumen-hoy');
    return ReporteDiario.fromJson(json as Map<String, Object?>);
  }

  @override
  Future<ReporteDiario> obtenerReporteDia(DateTime fecha) async {
    final json = await _apiClient.getJson(
      '/reportes/dia',
      queryParameters: {'fecha': _formatDate(fecha)},
    );
    return ReporteDiario.fromJson(json as Map<String, Object?>);
  }

  @override
  Future<DeudasResumen> obtenerDeudas() async {
    final json = await _apiClient.getJson('/reportes/deudas');
    return DeudasResumen.fromJson(json as Map<String, Object?>);
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
