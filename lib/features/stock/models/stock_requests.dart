class StockIniciarDiaRequest {
  const StockIniciarDiaRequest({
    required this.fecha,
    required this.stockInicial,
    this.observacion,
  });

  final DateTime fecha;
  final int stockInicial;
  final String? observacion;

  Map<String, Object?> toJson() {
    return {
      'fecha': _formatDate(fecha),
      'stock_inicial': stockInicial,
      if (observacion != null && observacion!.trim().isNotEmpty)
        'observacion': observacion!.trim(),
    };
  }
}

class StockEntradaRequest {
  const StockEntradaRequest({
    required this.fecha,
    required this.cantidad,
    this.observacion,
    this.pesoBalonKg,
  });

  final DateTime fecha;
  final int cantidad;
  final String? observacion;
  final int? pesoBalonKg;

  Map<String, Object?> toJson() {
    return {
      'fecha': _formatDate(fecha),
      'cantidad': cantidad,
      if (observacion != null && observacion!.trim().isNotEmpty)
        'observacion': observacion!.trim(),
      if (pesoBalonKg != null) 'peso_balon_kg': pesoBalonKg,
    };
  }
}

class StockAjusteRequest {
  const StockAjusteRequest({
    required this.fecha,
    required this.stockFisico,
    this.observacion,
    this.pesoBalonKg,
  });

  final DateTime fecha;
  final int stockFisico;
  final String? observacion;
  final int? pesoBalonKg;

  Map<String, Object?> toJson() {
    return {
      'fecha': _formatDate(fecha),
      'stock_fisico': stockFisico,
      if (observacion != null && observacion!.trim().isNotEmpty)
        'observacion': observacion!.trim(),
      if (pesoBalonKg != null) 'peso_balon_kg': pesoBalonKg,
    };
  }
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
