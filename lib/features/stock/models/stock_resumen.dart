import 'stock_por_peso.dart';

class StockResumen {
  const StockResumen({
    required this.fecha,
    required this.stockIniciado,
    required this.stockInicial,
    required this.entradas,
    int? compras,
    required this.salidas,
    required this.ajustes,
    required this.stockActual,
    required this.stockFinalFisico,
    required this.cerrado,
    this.porPeso,
  }) : compras = compras ?? entradas;

  final DateTime fecha;
  final bool stockIniciado;
  final int? stockInicial;
  final int entradas;
  final int compras;
  final int salidas;
  final int ajustes;
  final int? stockActual;
  final int? stockFinalFisico;
  final bool cerrado;
  final StockPorPeso? porPeso;

  factory StockResumen.fromJson(Map<String, Object?> json) {
    return StockResumen(
      fecha: DateTime.parse(json['fecha'] as String),
      stockIniciado: json['stock_iniciado'] as bool,
      stockInicial: json['stock_inicial'] as int?,
      entradas: _readInt(json['entradas']),
      compras: _readInt(json['compras'], fallback: json['entradas']),
      salidas: json['salidas'] as int? ?? 0,
      ajustes: json['ajustes'] as int? ?? 0,
      stockActual: json['stock_actual'] as int?,
      stockFinalFisico: json['stock_final_fisico'] as int?,
      cerrado: json['cerrado'] as bool? ?? false,
      porPeso: StockPorPeso.fromJson(json['por_peso'] as Map<String, Object?>?),
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
