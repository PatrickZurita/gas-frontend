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
  });

  final DateTime fecha;
  final int cantidad;
  final String? observacion;

  Map<String, Object?> toJson() {
    return {
      'fecha': _formatDate(fecha),
      'cantidad': cantidad,
      if (observacion != null && observacion!.trim().isNotEmpty)
        'observacion': observacion!.trim(),
    };
  }
}

class StockAjusteRequest {
  const StockAjusteRequest({
    required this.fecha,
    required this.stockFisico,
    this.observacion,
  });

  final DateTime fecha;
  final int stockFisico;
  final String? observacion;

  Map<String, Object?> toJson() {
    return {
      'fecha': _formatDate(fecha),
      'stock_fisico': stockFisico,
      if (observacion != null && observacion!.trim().isNotEmpty)
        'observacion': observacion!.trim(),
    };
  }
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
