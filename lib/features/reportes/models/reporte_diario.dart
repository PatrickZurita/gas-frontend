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
  });

  final DateTime fecha;
  final int pedidosCount;
  final int balonesVendidos;
  final int montoTotalCentavos;
  final int montoPagadoCentavos;
  final int montoPendienteCentavos;
  final List<PedidoReporte> pedidos;

  bool get isEmpty => pedidosCount == 0 && pedidos.isEmpty;

  factory ReporteDiario.fromJson(Map<String, Object?> json) {
    final pedidosJson = json['pedidos'] as List<Object?>;

    return ReporteDiario(
      fecha: DateTime.parse(json['fecha'] as String),
      pedidosCount: json['pedidos_count'] as int,
      balonesVendidos: json['balones_vendidos'] as int,
      montoTotalCentavos: json['monto_total_centavos'] as int,
      montoPagadoCentavos: json['monto_pagado_centavos'] as int,
      montoPendienteCentavos: json['monto_pendiente_centavos'] as int,
      pedidos:
          pedidosJson
              .map(
                (item) => PedidoReporte.fromJson(item as Map<String, Object?>),
              )
              .toList(),
    );
  }
}
