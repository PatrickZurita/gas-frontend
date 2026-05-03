class Cliente {
  const Cliente({
    required this.id,
    required this.alias,
    required this.telefono,
    this.direccion,
  });

  final int id;
  final String alias;
  final String telefono;
  final String? direccion;

  factory Cliente.fromJson(Map<String, Object?> json) {
    return Cliente(
      id: json['id'] as int,
      alias: json['alias'] as String,
      telefono: json['telefono'] as String,
      direccion: json['direccion'] as String?,
    );
  }
}
