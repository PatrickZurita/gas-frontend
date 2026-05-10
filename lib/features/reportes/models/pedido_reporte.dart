class PedidoReporte {
  const PedidoReporte({
    required this.id,
    required this.clienteId,
    required this.clienteAlias,
    required this.cantidadBalones,
    required this.montoTotalCentavos,
    required this.montoPendienteCentavos,
    required this.pagado,
    required this.fechaEntrega,
    required this.createdAt,
  });

  final int id;
  final int clienteId;
  final String clienteAlias;
  final int cantidadBalones;
  final int montoTotalCentavos;
  final int montoPendienteCentavos;
  final bool pagado;
  final DateTime fechaEntrega;
  final DateTime createdAt;

  factory PedidoReporte.fromJson(Map<String, Object?> json) {
    return PedidoReporte(
      id: json['id'] as int,
      clienteId: json['cliente_id'] as int,
      clienteAlias: json['cliente_alias'] as String,
      cantidadBalones: json['cantidad_balones'] as int,
      montoTotalCentavos: json['monto_total_centavos'] as int,
      montoPendienteCentavos: json['monto_pendiente_centavos'] as int,
      pagado: json['pagado'] as bool,
      fechaEntrega: DateTime.parse(json['fecha_entrega'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
