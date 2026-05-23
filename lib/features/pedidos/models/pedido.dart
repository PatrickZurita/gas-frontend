import '../../../core/network/json_helpers.dart';

enum PedidoEstado { activo, anulado }

PedidoEstado parsePedidoEstado(Object? value) {
  if (value is String && value.toUpperCase() == 'ANULADO') {
    return PedidoEstado.anulado;
  }
  return PedidoEstado.activo;
}

String pedidoEstadoToString(PedidoEstado estado) {
  return estado == PedidoEstado.anulado ? 'ANULADO' : 'ACTIVO';
}

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
    this.pesoBalonKg = 10,
    this.estado = PedidoEstado.activo,
    this.anuladoAt,
    this.anuladoMotivo,
    this.updatedAt,
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
  final int pesoBalonKg;
  final PedidoEstado estado;
  final DateTime? anuladoAt;
  final String? anuladoMotivo;
  final DateTime? updatedAt;

  bool get esAnulado => estado == PedidoEstado.anulado;

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
      pesoBalonKg: json['peso_balon_kg'] as int? ?? 10,
      estado: parsePedidoEstado(json['estado']),
      anuladoAt: _parseDateTime(json['anulado_at']),
      anuladoMotivo: json['anulado_motivo'] as String?,
      updatedAt: _parseDateTime(json['updated_at']),
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

  static DateTime? _parseDateTime(Object? value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
