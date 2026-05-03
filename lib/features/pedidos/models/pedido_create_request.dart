class PedidoCreateRequest {
  const PedidoCreateRequest({
    required this.clienteId,
    required this.cantidadBalones,
    required this.totalSoles,
    required this.pagado,
  });

  final int clienteId;
  final int cantidadBalones;
  final double totalSoles;
  final bool pagado;

  Map<String, Object?> toJson() {
    return {
      'cliente_id': clienteId,
      'cantidad_balones': cantidadBalones,
      'total_soles': totalSoles,
      'pagado': pagado,
    };
  }
}
