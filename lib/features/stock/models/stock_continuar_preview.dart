class StockContinuarPreview {
  const StockContinuarPreview({
    required this.puedeContinuar,
    this.fechaOrigen,
    this.stock10kg = 0,
    this.stock45kg = 0,
  });

  final bool puedeContinuar;
  final DateTime? fechaOrigen;
  final int stock10kg;
  final int stock45kg;

  int get total => stock10kg + stock45kg;

  factory StockContinuarPreview.fromJson(Map<String, Object?> json) {
    final fechaRaw = json['fecha_origen'] as String?;
    return StockContinuarPreview(
      puedeContinuar: json['puede_continuar'] as bool? ?? false,
      fechaOrigen: fechaRaw == null ? null : DateTime.parse(fechaRaw),
      stock10kg: json['stock_10kg'] as int? ?? 0,
      stock45kg: json['stock_45kg'] as int? ?? 0,
    );
  }
}
