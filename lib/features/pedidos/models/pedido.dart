import '../../../core/network/json_helpers.dart';

class Pedido {
  const Pedido({
    required this.id,
    required this.clienteId,
    required this.direccionId,
    required this.createdAt,
    required this.fechaEntrega,
    required this.cantidadBalones,
    required this.totalSoles,
    required this.pagado,
    required this.saldoPendiente,
    required this.marcaBalon,
    required this.tipoBalon,
    required this.precioUnitarioCentavos,
    required this.montoTotalCentavos,
    required this.montoPendienteCentavos,
  });

  final String id;
  final String clienteId;
  final String direccionId;
  final DateTime createdAt;
  final DateTime fechaEntrega;
  final int cantidadBalones;
  final double totalSoles;
  final bool pagado;
  final double saldoPendiente;
  final String marcaBalon;
  final String tipoBalon;
  final int? precioUnitarioCentavos;
  final int? montoTotalCentavos;
  final int? montoPendienteCentavos;

  factory Pedido.fromJson(Map<String, Object?> json) {
    return Pedido(
      id: parseId(json['id']),
      clienteId: parseId(json['cliente_id']),
      direccionId: parseId(json['direccion_id']),
      createdAt: DateTime.parse(json['created_at'] as String),
      fechaEntrega: DateTime.parse(json['fecha_entrega'] as String),
      cantidadBalones: json['cantidad_balones'] as int,
      totalSoles: _parseMoney(json['total_soles']),
      pagado: json['pagado'] as bool,
      saldoPendiente: _parseMoney(json['saldo_pendiente']),
      marcaBalon: json['marca_balon'] as String? ?? 'PETROPERU',
      tipoBalon: json['tipo_balon'] as String? ?? 'NORMAL',
      precioUnitarioCentavos: json['precio_unitario_centavos'] as int?,
      montoTotalCentavos: json['monto_total_centavos'] as int?,
      montoPendienteCentavos: json['monto_pendiente_centavos'] as int?,
    );
  }

  static double _parseMoney(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.parse(value);
    }
    throw FormatException('Monto invalido: $value');
  }
}
