import '../../../core/network/json_helpers.dart';

class DemandaPerdida {
  const DemandaPerdida({
    required this.id,
    required this.fecha,
    required this.motivo,
    required this.cantidadBalones,
    required this.pesoBalonKg,
    required this.createdAt,
    this.zonaTexto,
  });

  final String id;
  final DateTime fecha;
  final String motivo;
  final String? zonaTexto;
  final int cantidadBalones;
  final int pesoBalonKg;
  final DateTime createdAt;

  factory DemandaPerdida.fromJson(Map<String, Object?> json) {
    return DemandaPerdida(
      id: parseId(json['id']),
      fecha: DateTime.parse(json['fecha'] as String),
      motivo: json['motivo'] as String,
      zonaTexto: json['zona_texto'] as String?,
      cantidadBalones: json['cantidad_balones'] as int? ?? 1,
      pesoBalonKg: json['peso_balon_kg'] as int? ?? 10,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
