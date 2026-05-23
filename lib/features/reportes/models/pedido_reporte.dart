import '../../../core/network/json_helpers.dart';
import '../../pedidos/models/pedido.dart';

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
    this.pesoBalonKg = 10,
    this.estado = PedidoEstado.activo,
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
  final int pesoBalonKg;
  final PedidoEstado estado;

  bool get esAnulado => estado == PedidoEstado.anulado;

  Pedido toPedidoDetalle({String? direccionId}) {
    final totalSoles = montoTotalCentavos / 100.0;
    final saldoSoles = montoPendienteCentavos / 100.0;
    return Pedido(
      id: id,
      clienteId: clienteId,
      direccionId: direccionId ?? clienteId,
      createdAt: createdAt,
      fechaEntrega: fechaEntrega,
      cantidadBalones: cantidadBalones,
      totalSoles: totalSoles,
      pagado: pagado,
      saldoPendiente: saldoSoles,
      marcaBalon: marcaBalon,
      tipoBalon: tipoBalon,
      precioUnitarioCentavos: precioUnitarioCentavos,
      montoTotalCentavos: montoTotalCentavos,
      montoPendienteCentavos: montoPendienteCentavos,
      pesoBalonKg: pesoBalonKg,
      estado: estado,
    );
  }

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
      pesoBalonKg: json['peso_balon_kg'] as int? ?? 10,
      estado: parsePedidoEstado(json['estado']),
    );
  }
}
