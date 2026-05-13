/// Normaliza un ID que puede llegar como int (PostgreSQL) o String (DynamoDB).
String parseId(Object? value) {
  if (value is String) return value;
  if (value is int) return value.toString();
  throw FormatException('ID invalido: $value');
}

String? parseIdNullable(Object? value) {
  if (value == null) return null;
  return parseId(value);
}

/// Si el ID es numerico (PostgreSQL), lo manda como int para preservar
/// compatibilidad con Pydantic `int`. Si es UUID (DynamoDB futuro), lo manda
/// como string. Backend con `Union[int, str]` acepta ambos.
Object encodeIdForBackend(String id) {
  final asInt = int.tryParse(id);
  return asInt ?? id;
}
