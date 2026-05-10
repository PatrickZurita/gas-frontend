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

  final int id;
  final String tipo;
  final int cantidadDelta;
  final int stockResultante;
  final int? pedidoId;
  final String? observacion;
  final DateTime createdAt;

  factory MovimientoStock.fromJson(Map<String, Object?> json) {
    return MovimientoStock(
      id: json['id'] as int,
      tipo: json['tipo'] as String,
      cantidadDelta: json['cantidad_delta'] as int,
      stockResultante: json['stock_resultante'] as int,
      pedidoId: json['pedido_id'] as int?,
      observacion: json['observacion'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
