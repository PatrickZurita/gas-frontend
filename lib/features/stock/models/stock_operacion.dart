class StockOperacion {
  const StockOperacion({
    required this.fecha,
    required this.tipo,
    required this.cantidadDelta,
    required this.stockActual,
    required this.observacion,
  });

  final DateTime fecha;
  final String tipo;
  final int cantidadDelta;
  final int stockActual;
  final String? observacion;

  factory StockOperacion.fromJson(Map<String, Object?> json) {
    return StockOperacion(
      fecha: DateTime.parse(json['fecha'] as String),
      tipo: json['tipo'] as String,
      cantidadDelta: json['cantidad_delta'] as int,
      stockActual: json['stock_actual'] as int,
      observacion: json['observacion'] as String?,
    );
  }
}
