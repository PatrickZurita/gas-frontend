class StockPorPeso {
  const StockPorPeso({
    required this.stockActual10kg,
    required this.stockActual45kg,
    this.inicio10kg,
    this.inicio45kg,
    this.salidas10kg = 0,
    this.salidas45kg = 0,
    this.entradas10kg = 0,
    this.entradas45kg = 0,
    int? compras10kg,
    int? compras45kg,
    this.ajustes10kg = 0,
    this.ajustes45kg = 0,
    this.reversas10kg = 0,
    this.reversas45kg = 0,
  }) : compras10kg = compras10kg ?? entradas10kg,
       compras45kg = compras45kg ?? entradas45kg;

  final int? stockActual10kg;
  final int? stockActual45kg;
  final int? inicio10kg;
  final int? inicio45kg;
  final int salidas10kg;
  final int salidas45kg;
  final int entradas10kg;
  final int entradas45kg;
  final int compras10kg;
  final int compras45kg;
  final int ajustes10kg;
  final int ajustes45kg;
  final int reversas10kg;
  final int reversas45kg;

  bool get sinStock10kg => (stockActual10kg ?? 0) <= 0;
  bool get sinStock45kg => (stockActual45kg ?? 0) <= 0;

  /// Backend nuevo devuelve `inicio` y `compras` por peso.
  /// Payloads legacy usan `entradas`; se mantiene como fallback temporal.
  static StockPorPeso? fromJson(Map<String, Object?>? json) {
    if (json == null) {
      return null;
    }
    final diezKg = json['10kg'] as Map<String, Object?>? ?? const {};
    final cuarentaYCincoKg = json['45kg'] as Map<String, Object?>? ?? const {};
    return StockPorPeso(
      stockActual10kg: _readIntOrNull(diezKg['stock_disponible']),
      stockActual45kg: _readIntOrNull(cuarentaYCincoKg['stock_disponible']),
      inicio10kg: _readIntOrNull(diezKg['inicio']),
      inicio45kg: _readIntOrNull(cuarentaYCincoKg['inicio']),
      salidas10kg: _readInt(diezKg['salidas']),
      salidas45kg: _readInt(cuarentaYCincoKg['salidas']),
      entradas10kg: _readInt(diezKg['entradas']),
      entradas45kg: _readInt(cuarentaYCincoKg['entradas']),
      compras10kg: _readInt(diezKg['compras'], fallback: diezKg['entradas']),
      compras45kg: _readInt(
        cuarentaYCincoKg['compras'],
        fallback: cuarentaYCincoKg['entradas'],
      ),
      ajustes10kg: _readInt(diezKg['ajustes']),
      ajustes45kg: _readInt(cuarentaYCincoKg['ajustes']),
      reversas10kg: _readInt(diezKg['reversas']),
      reversas45kg: _readInt(cuarentaYCincoKg['reversas']),
    );
  }

  static int _readInt(Object? value, {Object? fallback}) {
    return _readIntOrNull(value) ?? _readIntOrNull(fallback) ?? 0;
  }

  static int? _readIntOrNull(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }
}
