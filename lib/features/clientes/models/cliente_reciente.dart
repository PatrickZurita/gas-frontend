import '../../../core/network/json_helpers.dart';
import 'cliente.dart';

class ClienteReciente {
  const ClienteReciente({
    required this.id,
    required this.alias,
    required this.telefono,
    required this.direccion,
    required this.ultimoPedidoFecha,
    required this.ultimoTotalCentavos,
  });

  final String id;
  final String alias;
  final String telefono;
  final String direccion;
  final DateTime ultimoPedidoFecha;
  final int ultimoTotalCentavos;

  factory ClienteReciente.fromJson(Map<String, Object?> json) {
    return ClienteReciente(
      id: parseId(json['id']),
      alias: json['alias'] as String,
      telefono: json['telefono'] as String,
      direccion: json['direccion'] as String,
      ultimoPedidoFecha: DateTime.parse(json['ultimo_pedido_fecha'] as String),
      ultimoTotalCentavos: json['ultimo_total_centavos'] as int,
    );
  }

  Cliente toCliente() {
    return Cliente(
      id: id,
      alias: alias,
      telefono: telefono,
      direccion: direccion,
    );
  }
}
