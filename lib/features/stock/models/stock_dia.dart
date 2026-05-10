import 'movimiento_stock.dart';
import 'stock_resumen.dart';

class StockDia extends StockResumen {
  const StockDia({
    required super.fecha,
    required super.stockIniciado,
    required super.stockInicial,
    required super.entradas,
    required super.salidas,
    required super.ajustes,
    required super.stockActual,
    required super.stockFinalFisico,
    required super.cerrado,
    required this.movimientos,
  });

  final List<MovimientoStock> movimientos;

  factory StockDia.fromJson(Map<String, Object?> json) {
    final movimientosJson = json['movimientos'] as List<Object?>? ?? const [];

    return StockDia(
      fecha: DateTime.parse(json['fecha'] as String),
      stockIniciado: json['stock_iniciado'] as bool,
      stockInicial: json['stock_inicial'] as int?,
      entradas: json['entradas'] as int? ?? 0,
      salidas: json['salidas'] as int? ?? 0,
      ajustes: json['ajustes'] as int? ?? 0,
      stockActual: json['stock_actual'] as int?,
      stockFinalFisico: json['stock_final_fisico'] as int?,
      cerrado: json['cerrado'] as bool? ?? false,
      movimientos:
          movimientosJson
              .map(
                (item) =>
                    MovimientoStock.fromJson(item as Map<String, Object?>),
              )
              .toList(),
    );
  }
}
