class ClienteCreateRequest {
  const ClienteCreateRequest({
    required this.alias,
    required this.telefono,
    this.canalCaptacion,
  });

  final String alias;
  final String telefono;

  /// P1 #1: canal de captacion en MAYUSCULAS (VOLANTE, FACEBOOK,
  /// RECOMENDACION, CARTEL, ANTIGUO, OTRO). Opcional: si el operador no
  /// elige nada queda null y el campo se omite del body.
  final String? canalCaptacion;

  Map<String, Object?> toJson() {
    return {
      'alias': alias,
      'telefono': telefono,
      if (canalCaptacion != null) 'canal_captacion': canalCaptacion,
    };
  }
}
