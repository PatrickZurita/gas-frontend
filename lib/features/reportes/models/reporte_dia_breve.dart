class ReporteDiaBreve {
  const ReporteDiaBreve({
    required this.fecha,
    required this.pedidosCount,
    required this.balonesVendidos,
    required this.balonesVendidos10kg,
    required this.balonesVendidos45kg,
    required this.montoTotalCentavos,
    required this.montoCobradoCentavos,
    required this.montoPendienteCentavos,
  });

  final DateTime fecha;
  final int pedidosCount;
  final int balonesVendidos;
  final int balonesVendidos10kg;
  final int balonesVendidos45kg;
  final int montoTotalCentavos;
  final int montoCobradoCentavos;
  final int montoPendienteCentavos;

  factory ReporteDiaBreve.fromJson(Map<String, Object?> json) {
    return ReporteDiaBreve(
      fecha: DateTime.parse(json['fecha'] as String),
      pedidosCount: json['pedidos_count'] as int? ?? 0,
      balonesVendidos: json['balones_vendidos'] as int? ?? 0,
      balonesVendidos10kg: json['balones_vendidos_10kg'] as int? ?? 0,
      balonesVendidos45kg: json['balones_vendidos_45kg'] as int? ?? 0,
      montoTotalCentavos: json['monto_total_centavos'] as int? ?? 0,
      montoCobradoCentavos: json['monto_cobrado_centavos'] as int? ?? 0,
      montoPendienteCentavos: json['monto_pendiente_centavos'] as int? ?? 0,
    );
  }
}
