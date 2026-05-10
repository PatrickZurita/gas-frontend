import 'pedido_reporte.dart';

class DeudasResumen {
  const DeudasResumen({
    required this.pedidosCount,
    required this.montoPendienteCentavos,
    required this.pedidos,
  });

  final int pedidosCount;
  final int montoPendienteCentavos;
  final List<PedidoReporte> pedidos;

  factory DeudasResumen.fromJson(Map<String, Object?> json) {
    final pedidosJson = json['pedidos'] as List<Object?>;

    return DeudasResumen(
      pedidosCount: json['pedidos_count'] as int,
      montoPendienteCentavos: json['monto_pendiente_centavos'] as int,
      pedidos:
          pedidosJson
              .map(
                (item) => PedidoReporte.fromJson(item as Map<String, Object?>),
              )
              .toList(),
    );
  }
}
