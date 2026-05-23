import 'reporte_dia_breve.dart';

class ReporteMensual {
  const ReporteMensual({
    required this.mes,
    required this.pedidosCount,
    required this.balonesVendidos,
    required this.balonesVendidos10kg,
    required this.balonesVendidos45kg,
    required this.montoTotalCentavos,
    required this.montoCobradoCentavos,
    required this.montoPendienteCentavos,
    required this.dias,
  });

  final String mes;
  final int pedidosCount;
  final int balonesVendidos;
  final int balonesVendidos10kg;
  final int balonesVendidos45kg;
  final int montoTotalCentavos;
  final int montoCobradoCentavos;
  final int montoPendienteCentavos;
  final List<ReporteDiaBreve> dias;

  bool get isEmpty => pedidosCount == 0 && dias.isEmpty;

  factory ReporteMensual.fromJson(Map<String, Object?> json) {
    final diasJson = json['dias'] as List<Object?>? ?? const [];
    final balones10 = json['balones_10kg'] as int? ?? 0;
    final balones45 = json['balones_45kg'] as int? ?? 0;
    return ReporteMensual(
      mes: json['mes'] as String,
      pedidosCount: json['total_pedidos'] as int? ?? 0,
      balonesVendidos: balones10 + balones45,
      balonesVendidos10kg: balones10,
      balonesVendidos45kg: balones45,
      montoTotalCentavos: json['total_vendido_centavos'] as int? ?? 0,
      montoCobradoCentavos: json['total_cobrado_centavos'] as int? ?? 0,
      montoPendienteCentavos: json['total_pendiente_centavos'] as int? ?? 0,
      dias:
          diasJson
              .map(
                (item) =>
                    ReporteDiaBreve.fromJson(item as Map<String, Object?>),
              )
              .toList(),
    );
  }
}
