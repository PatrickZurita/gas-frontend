import 'pedido_reporte.dart';

class ReporteDiario {
  const ReporteDiario({
    required this.fecha,
    required this.pedidosCount,
    required this.balonesVendidos,
    required this.montoTotalCentavos,
    required this.montoPagadoCentavos,
    required this.montoPendienteCentavos,
    required this.pedidos,
    this.montoCobradoEfectivoCentavos = 0,
    this.montoCobradoYapeCentavos = 0,
  });

  final DateTime fecha;
  final int pedidosCount;
  final int balonesVendidos;
  final int montoTotalCentavos;
  final int montoPagadoCentavos;
  final int montoPendienteCentavos;
  final int montoCobradoEfectivoCentavos;
  final int montoCobradoYapeCentavos;
  final List<PedidoReporte> pedidos;

  bool get isEmpty => pedidosCount == 0 && pedidos.isEmpty;

  /// Cobrado total atribuible a un metodo (efectivo + yape). Pedidos
  /// pagados sin metodo (legacy) NO se cuentan aqui; ver `montoPagadoCentavos`
  /// para el cobrado bruto del dia.
  int get cobradoConMetodoCentavos =>
      montoCobradoEfectivoCentavos + montoCobradoYapeCentavos;

  factory ReporteDiario.fromJson(Map<String, Object?> json) {
    final pedidosJson = json['pedidos'] as List<Object?>;

    return ReporteDiario(
      fecha: DateTime.parse(json['fecha'] as String),
      pedidosCount: json['pedidos_count'] as int,
      balonesVendidos: json['balones_vendidos'] as int,
      montoTotalCentavos: json['monto_total_centavos'] as int,
      montoPagadoCentavos: json['monto_pagado_centavos'] as int,
      montoPendienteCentavos: json['monto_pendiente_centavos'] as int,
      montoCobradoEfectivoCentavos:
          json['monto_cobrado_efectivo_centavos'] as int? ?? 0,
      montoCobradoYapeCentavos:
          json['monto_cobrado_yape_centavos'] as int? ?? 0,
      pedidos:
          pedidosJson
              .map(
                (item) => PedidoReporte.fromJson(item as Map<String, Object?>),
              )
              .toList(),
    );
  }
}
