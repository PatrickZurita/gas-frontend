class CatalogoItem {
  const CatalogoItem({required this.codigo, required this.nombre});

  final String codigo;
  final String nombre;

  factory CatalogoItem.fromJson(Map<String, Object?> json) {
    return CatalogoItem(
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
    );
  }
}
