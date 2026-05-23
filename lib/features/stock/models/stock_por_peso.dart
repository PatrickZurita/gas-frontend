class StockPorPeso {
  const StockPorPeso({
    required this.stockActual10kg,
    required this.stockActual45kg,
    this.salidas10kg = 0,
    this.salidas45kg = 0,
    this.entradas10kg = 0,
    this.entradas45kg = 0,
    this.ajustes10kg = 0,
    this.ajustes45kg = 0,
  });

  final int? stockActual10kg;
  final int? stockActual45kg;
  final int salidas10kg;
  final int salidas45kg;
  final int entradas10kg;
  final int entradas45kg;
  final int ajustes10kg;
  final int ajustes45kg;

  static StockPorPeso? fromJson(Map<String, Object?>? json) {
    if (json == null) {
      return null;
    }
    return StockPorPeso(
      stockActual10kg: json['stock_actual_10kg'] as int?,
      stockActual45kg: json['stock_actual_45kg'] as int?,
      salidas10kg: json['salidas_10kg'] as int? ?? 0,
      salidas45kg: json['salidas_45kg'] as int? ?? 0,
      entradas10kg: json['entradas_10kg'] as int? ?? 0,
      entradas45kg: json['entradas_45kg'] as int? ?? 0,
      ajustes10kg: json['ajustes_10kg'] as int? ?? 0,
      ajustes45kg: json['ajustes_45kg'] as int? ?? 0,
    );
  }
}
