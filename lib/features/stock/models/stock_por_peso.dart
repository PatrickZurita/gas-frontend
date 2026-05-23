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
    this.reversas10kg = 0,
    this.reversas45kg = 0,
  });

  final int? stockActual10kg;
  final int? stockActual45kg;
  final int salidas10kg;
  final int salidas45kg;
  final int entradas10kg;
  final int entradas45kg;
  final int ajustes10kg;
  final int ajustes45kg;
  final int reversas10kg;
  final int reversas45kg;

  bool get sinStock10kg => (stockActual10kg ?? 0) <= 0;
  bool get sinStock45kg => (stockActual45kg ?? 0) <= 0;

  /// Backend devuelve:
  /// `por_peso: { "10kg": {salidas, entradas, reversas, ajustes, stock_disponible},
  ///              "45kg": {...} }`
  static StockPorPeso? fromJson(Map<String, Object?>? json) {
    if (json == null) {
      return null;
    }
    final diezKg = json['10kg'] as Map<String, Object?>? ?? const {};
    final cuarentaYCincoKg = json['45kg'] as Map<String, Object?>? ?? const {};
    return StockPorPeso(
      stockActual10kg: diezKg['stock_disponible'] as int?,
      stockActual45kg: cuarentaYCincoKg['stock_disponible'] as int?,
      salidas10kg: diezKg['salidas'] as int? ?? 0,
      salidas45kg: cuarentaYCincoKg['salidas'] as int? ?? 0,
      entradas10kg: diezKg['entradas'] as int? ?? 0,
      entradas45kg: cuarentaYCincoKg['entradas'] as int? ?? 0,
      ajustes10kg: diezKg['ajustes'] as int? ?? 0,
      ajustes45kg: cuarentaYCincoKg['ajustes'] as int? ?? 0,
      reversas10kg: diezKg['reversas'] as int? ?? 0,
      reversas45kg: cuarentaYCincoKg['reversas'] as int? ?? 0,
    );
  }
}
