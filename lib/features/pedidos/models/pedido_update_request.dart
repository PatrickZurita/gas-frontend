class PedidoUpdateRequest {
  const PedidoUpdateRequest({
    this.cantidadBalones,
    this.fechaEntrega,
    this.pagado,
    this.pesoBalonKg,
    this.marcaBalon,
    this.tipoBalon,
    this.precioUnitarioCentavos,
    this.montoTotalCentavos,
    this.montoPendienteCentavos,
    this.motivoEdicion,
  });

  final int? cantidadBalones;
  final DateTime? fechaEntrega;
  final bool? pagado;
  final int? pesoBalonKg;
  final String? marcaBalon;
  final String? tipoBalon;
  final int? precioUnitarioCentavos;
  final int? montoTotalCentavos;
  final int? montoPendienteCentavos;
  final String? motivoEdicion;

  bool get isEmpty =>
      cantidadBalones == null &&
      fechaEntrega == null &&
      pagado == null &&
      pesoBalonKg == null &&
      marcaBalon == null &&
      tipoBalon == null &&
      precioUnitarioCentavos == null &&
      montoTotalCentavos == null &&
      montoPendienteCentavos == null &&
      motivoEdicion == null;

  Map<String, Object?> toJson() {
    return {
      if (cantidadBalones != null) 'cantidad_balones': cantidadBalones,
      if (fechaEntrega != null) 'fecha_entrega': _formatDate(fechaEntrega!),
      if (pagado != null) 'pagado': pagado,
      if (pesoBalonKg != null) 'peso_balon_kg': pesoBalonKg,
      if (marcaBalon != null) 'marca_balon': marcaBalon,
      if (tipoBalon != null) 'tipo_balon': tipoBalon,
      if (precioUnitarioCentavos != null)
        'precio_unitario_centavos': precioUnitarioCentavos,
      if (montoTotalCentavos != null)
        'monto_total_centavos': montoTotalCentavos,
      if (montoPendienteCentavos != null)
        'monto_pendiente_centavos': montoPendienteCentavos,
      if (motivoEdicion != null) 'motivo_edicion': motivoEdicion,
    };
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
