import '../../../core/network/json_helpers.dart';

class MovimientoStock {
  const MovimientoStock({
    required this.id,
    required this.tipo,
    required this.cantidadDelta,
    required this.stockResultante,
    required this.pedidoId,
    required this.observacion,
    required this.createdAt,
  });

  final String id;
  final String tipo;
  final int cantidadDelta;
  final int stockResultante;
  final String? pedidoId;
  final String? observacion;
  final DateTime createdAt;

  factory MovimientoStock.fromJson(Map<String, Object?> json) {
    return MovimientoStock(
      id: parseId(json['id']),
      tipo: json['tipo'] as String,
      cantidadDelta: json['cantidad_delta'] as int,
      stockResultante: json['stock_resultante'] as int,
      pedidoId: parseIdNullable(json['pedido_id']),
      observacion: json['observacion'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
