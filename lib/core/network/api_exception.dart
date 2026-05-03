class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode, this.body});

  final String message;
  final int? statusCode;
  final String? body;

  @override
  String toString() {
    final code = statusCode == null ? '' : ' ($statusCode)';
    return 'ApiException$code: $message';
  }
}

class NetworkException extends ApiException {
  const NetworkException({required super.message, super.body});
}
