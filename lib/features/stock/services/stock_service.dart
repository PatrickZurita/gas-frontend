import '../../../core/network/api_client.dart';
import '../models/catalogo_item.dart';
import '../models/stock_continuar_preview.dart';
import '../models/stock_dia.dart';
import '../models/stock_operacion.dart';
import '../models/stock_requests.dart';
import '../models/stock_resumen.dart';

abstract interface class StockService {
  Future<StockResumen> obtenerResumenHoy();

  Future<StockDia> obtenerStockDia(DateTime fecha);

  Future<StockOperacion> iniciarDia(StockIniciarDiaRequest request);

  Future<StockOperacion> registrarEntrada(StockEntradaRequest request);

  Future<StockOperacion> ajustarStock(StockAjusteRequest request);

  Future<List<CatalogoItem>> obtenerTiposBalon();

  Future<List<CatalogoItem>> obtenerMarcasBalon();

  Future<StockContinuarPreview> obtenerPreviewContinuar();

  Future<StockResumen> continuarDeAyer();
}

class ApiStockService implements StockService {
  const ApiStockService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<StockResumen> obtenerResumenHoy() async {
    final json = await _apiClient.getJson('/stock/resumen-hoy');
    return StockResumen.fromJson(json as Map<String, Object?>);
  }

  @override
  Future<StockDia> obtenerStockDia(DateTime fecha) async {
    final json = await _apiClient.getJson(
      '/stock/dia',
      queryParameters: {'fecha': _formatDate(fecha)},
    );
    return StockDia.fromJson(json as Map<String, Object?>);
  }

  @override
  Future<StockOperacion> iniciarDia(StockIniciarDiaRequest request) async {
    final json = await _apiClient.postJson(
      '/stock/iniciar-dia',
      body: request.toJson(),
    );
    return StockOperacion.fromJson(json as Map<String, Object?>);
  }

  @override
  Future<StockOperacion> registrarEntrada(StockEntradaRequest request) async {
    final json = await _apiClient.postJson(
      '/stock/entrada',
      body: request.toJson(),
    );
    return StockOperacion.fromJson(json as Map<String, Object?>);
  }

  @override
  Future<StockOperacion> ajustarStock(StockAjusteRequest request) async {
    final json = await _apiClient.postJson(
      '/stock/ajuste',
      body: request.toJson(),
    );
    return StockOperacion.fromJson(json as Map<String, Object?>);
  }

  @override
  Future<List<CatalogoItem>> obtenerTiposBalon() async {
    return _catalogo('/catalogos/tipos-balon');
  }

  @override
  Future<List<CatalogoItem>> obtenerMarcasBalon() async {
    return _catalogo('/catalogos/marcas-balon');
  }

  @override
  Future<StockContinuarPreview> obtenerPreviewContinuar() async {
    final json = await _apiClient.getJson('/stock/preview-continuar');
    return StockContinuarPreview.fromJson(json as Map<String, Object?>);
  }

  @override
  Future<StockResumen> continuarDeAyer() async {
    final json = await _apiClient.postJson('/stock/continuar-de-ayer');
    return StockResumen.fromJson(json as Map<String, Object?>);
  }

  Future<List<CatalogoItem>> _catalogo(String path) async {
    final json = await _apiClient.getJson(path) as Map<String, Object?>;
    final items = json['items'] as List<Object?>;
    return items
        .map((item) => CatalogoItem.fromJson(item as Map<String, Object?>))
        .toList();
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
