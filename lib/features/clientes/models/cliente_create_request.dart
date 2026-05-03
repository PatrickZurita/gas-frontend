class ClienteCreateRequest {
  const ClienteCreateRequest({required this.alias, required this.telefono});

  final String alias;
  final String telefono;

  Map<String, Object?> toJson() {
    return {'alias': alias, 'telefono': telefono};
  }
}
