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
    this.compras10kg = 0,
    this.compras45kg = 0,
    this.stockFinal10kg = 0,
    this.stockFinal45kg = 0,
    this.montoCobradoEfectivoCentavos = 0,
    this.montoCobradoYapeCentavos = 0,
  });

  final DateTime fecha;
  final int pedidosCount;
  final int balonesVendidos;
  final int balonesVendidos10kg;
  final int balonesVendidos45kg;
  final int montoTotalCentavos;
  final int montoCobradoCentavos;
  final int montoPendienteCentavos;
  final int compras10kg;
  final int compras45kg;
  final int stockFinal10kg;
  final int stockFinal45kg;
  final int montoCobradoEfectivoCentavos;
  final int montoCobradoYapeCentavos;

  factory ReporteDiaBreve.fromJson(Map<String, Object?> json) {
    final balones10 = json['balones_10kg'] as int? ?? 0;
    final balones45 = json['balones_45kg'] as int? ?? 0;
    return ReporteDiaBreve(
      fecha: DateTime.parse(json['fecha'] as String),
      pedidosCount: json['pedidos_count'] as int? ?? 0,
      balonesVendidos: balones10 + balones45,
      balonesVendidos10kg: balones10,
      balonesVendidos45kg: balones45,
      montoTotalCentavos: json['vendido_centavos'] as int? ?? 0,
      montoCobradoCentavos: json['cobrado_centavos'] as int? ?? 0,
      montoPendienteCentavos: json['pendiente_centavos'] as int? ?? 0,
      compras10kg: json['compras_10kg'] as int? ?? 0,
      compras45kg: json['compras_45kg'] as int? ?? 0,
      stockFinal10kg: json['stock_final_10kg'] as int? ?? 0,
      stockFinal45kg: json['stock_final_45kg'] as int? ?? 0,
      montoCobradoEfectivoCentavos:
          json['cobrado_efectivo_centavos'] as int? ?? 0,
      montoCobradoYapeCentavos: json['cobrado_yape_centavos'] as int? ?? 0,
    );
  }
}
