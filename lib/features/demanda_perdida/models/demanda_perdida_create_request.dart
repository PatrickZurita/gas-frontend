/// Motivos validos del contrato POST /demanda-perdida (P1 #2).
abstract final class DemandaPerdidaMotivo {
  static const String sinStock = 'SIN_STOCK';
  static const String fueraDeZona = 'FUERA_DE_ZONA';
  static const String saturado = 'SATURADO';
  static const String otro = 'OTRO';
}

/// Body de POST /demanda-perdida. Solo `motivo` es obligatorio: los
/// opcionales se omiten del JSON cuando el operador no los toco, para
/// mandar el body minimo `{"motivo": "..."}` (el backend pone los defaults
/// cantidad_balones=1 y peso_balon_kg=10).
class DemandaPerdidaCreateRequest {
  const DemandaPerdidaCreateRequest({
    required this.motivo,
    this.cantidadBalones,
    this.pesoBalonKg,
    this.zonaTexto,
  });

  final String motivo;
  final int? cantidadBalones;
  final int? pesoBalonKg;
  final String? zonaTexto;

  Map<String, Object?> toJson() {
    final zona = zonaTexto?.trim();
    return {
      'motivo': motivo,
      if (cantidadBalones != null) 'cantidad_balones': cantidadBalones,
      if (pesoBalonKg != null) 'peso_balon_kg': pesoBalonKg,
      if (zona != null && zona.isNotEmpty) 'zona_texto': zona,
    };
  }
}
