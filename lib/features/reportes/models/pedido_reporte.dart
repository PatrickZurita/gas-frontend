import '../../../core/network/json_helpers.dart';

class PedidoReporte {
  const PedidoReporte({
    required this.id,
    required this.clienteId,
    required this.clienteAlias,
    required this.cantidadBalones,
    required this.marcaBalon,
    required this.tipoBalon,
    required this.precioUnitarioCentavos,
    required this.montoTotalCentavos,
    required this.montoPendienteCentavos,
    required this.pagado,
    required this.fechaEntrega,
    required this.createdAt,
  });

  final String id;
  final String clienteId;
  final String clienteAlias;
  final int cantidadBalones;
  final String marcaBalon;
  final String tipoBalon;
  final int? precioUnitarioCentavos;
  final int montoTotalCentavos;
  final int montoPendienteCentavos;
  final bool pagado;
  final DateTime fechaEntrega;
  final DateTime createdAt;

  factory PedidoReporte.fromJson(Map<String, Object?> json) {
    return PedidoReporte(
      id: parseId(json['id']),
      clienteId: parseId(json['cliente_id']),
      clienteAlias: json['cliente_alias'] as String,
      cantidadBalones: json['cantidad_balones'] as int,
      marcaBalon: json['marca_balon'] as String? ?? 'PETROPERU',
      tipoBalon: json['tipo_balon'] as String? ?? 'NORMAL',
      precioUnitarioCentavos: json['precio_unitario_centavos'] as int?,
      montoTotalCentavos: json['monto_total_centavos'] as int,
      montoPendienteCentavos: json['monto_pendiente_centavos'] as int,
      pagado: json['pagado'] as bool,
      fechaEntrega: DateTime.parse(json['fecha_entrega'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
