import '../../../core/network/api_client.dart';
import '../models/deudas_resumen.dart';
import '../models/reporte_diario.dart';
import '../models/reporte_mensual.dart';
import '../models/reporte_semanal.dart';

abstract interface class ReportesService {
  Future<ReporteDiario> obtenerResumenHoy();

  Future<ReporteDiario> obtenerReporteDia(DateTime fecha);

  Future<DeudasResumen> obtenerDeudas();

  Future<ReporteSemanal> obtenerReporteSemana(DateTime desde);

  Future<ReporteMensual> obtenerReporteMes(DateTime mes);
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

  @override
  Future<ReporteSemanal> obtenerReporteSemana(DateTime desde) async {
    final json = await _apiClient.getJson(
      '/reportes/semana',
      queryParameters: {'desde': _formatDate(desde)},
    );
    return ReporteSemanal.fromJson(json as Map<String, Object?>);
  }

  @override
  Future<ReporteMensual> obtenerReporteMes(DateTime mes) async {
    final json = await _apiClient.getJson(
      '/reportes/mes',
      queryParameters: {'mes': _formatMonth(mes)},
    );
    return ReporteMensual.fromJson(json as Map<String, Object?>);
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _formatMonth(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month';
  }
}
