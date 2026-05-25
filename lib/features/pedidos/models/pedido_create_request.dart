import '../../../core/network/json_helpers.dart';
import 'pedido.dart';

class PedidoCreateRequest {
  const PedidoCreateRequest({
    required this.clienteId,
    required this.cantidadBalones,
    this.totalSoles,
    required this.pagado,
    this.marcaBalon = 'PETROPERU',
    this.tipoBalon = 'NORMAL',
    this.pesoBalonKg = 10,
    this.precioUnitarioCentavos,
    this.montoTotalCentavos,
    this.montoPendienteCentavos,
    this.metodoPago,
  });

  final String clienteId;
  final int cantidadBalones;
  final bool pagado;
  final double? totalSoles;
  final String marcaBalon;
  final String tipoBalon;
  final int pesoBalonKg;
  final int? precioUnitarioCentavos;
  final int? montoTotalCentavos;
  final int? montoPendienteCentavos;

  /// Solo aplica cuando `pagado=true`. Backend valida y rechaza con 422 si
  /// se envia `metodo_pago` con `pagado=false`.
  final MetodoPago? metodoPago;

  Map<String, Object?> toJson() {
    return {
      'cliente_id': encodeIdForBackend(clienteId),
      'cantidad_balones': cantidadBalones,
      'pagado': pagado,
      'marca_balon': marcaBalon,
      'tipo_balon': tipoBalon,
      'peso_balon_kg': pesoBalonKg,
      if (precioUnitarioCentavos != null)
        'precio_unitario_centavos': precioUnitarioCentavos,
      if (montoTotalCentavos != null)
        'monto_total_centavos': montoTotalCentavos,
      if (montoPendienteCentavos != null)
        'monto_pendiente_centavos': montoPendienteCentavos,
      if (totalSoles != null) 'total_soles': totalSoles,
      if (metodoPago != null && pagado)
        'metodo_pago': metodoPagoToBackend(metodoPago!),
    };
  }

  double get legacyTotalSoles {
    final centavos = montoTotalCentavos;
    if (centavos != null) {
      return centavos / 100;
    }
    return totalSoles ?? 0;
  }
}
