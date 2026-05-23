import 'reporte_dia_breve.dart';

class ReporteSemanal {
  const ReporteSemanal({
    required this.desde,
    required this.hasta,
    required this.pedidosCount,
    required this.balonesVendidos,
    required this.balonesVendidos10kg,
    required this.balonesVendidos45kg,
    required this.montoTotalCentavos,
    required this.montoCobradoCentavos,
    required this.montoPendienteCentavos,
    required this.dias,
  });

  final DateTime desde;
  final DateTime hasta;
  final int pedidosCount;
  final int balonesVendidos;
  final int balonesVendidos10kg;
  final int balonesVendidos45kg;
  final int montoTotalCentavos;
  final int montoCobradoCentavos;
  final int montoPendienteCentavos;
  final List<ReporteDiaBreve> dias;

  bool get isEmpty => pedidosCount == 0 && dias.isEmpty;

  factory ReporteSemanal.fromJson(Map<String, Object?> json) {
    final diasJson = json['dias'] as List<Object?>? ?? const [];
    return ReporteSemanal(
      desde: DateTime.parse(json['desde'] as String),
      hasta: DateTime.parse(json['hasta'] as String),
      pedidosCount: json['pedidos_count'] as int? ?? 0,
      balonesVendidos: json['balones_vendidos'] as int? ?? 0,
      balonesVendidos10kg: json['balones_vendidos_10kg'] as int? ?? 0,
      balonesVendidos45kg: json['balones_vendidos_45kg'] as int? ?? 0,
      montoTotalCentavos: json['monto_total_centavos'] as int? ?? 0,
      montoCobradoCentavos: json['monto_cobrado_centavos'] as int? ?? 0,
      montoPendienteCentavos: json['monto_pendiente_centavos'] as int? ?? 0,
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
