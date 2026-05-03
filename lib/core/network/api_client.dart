import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    String? baseUrl,
    this.timeout = const Duration(seconds: 10),
  }) : _httpClient = httpClient ?? http.Client(),
       _baseUri = Uri.parse(baseUrl ?? AppConfig.baseUrl);

  final http.Client _httpClient;
  final Uri _baseUri;
  final Duration timeout;

  static const Map<String, String> jsonHeaders = {
    HttpHeaders.acceptHeader: 'application/json',
    HttpHeaders.contentTypeHeader: 'application/json',
  };

  Future<Object?> getJson(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final response = await _send(
      () => _httpClient.get(
        _buildUri(path, queryParameters: queryParameters),
        headers: jsonHeaders,
      ),
    );
    return _decodeSuccess(response);
  }

  Future<Object?> postJson(String path, {Map<String, Object?>? body}) async {
    final response = await _send(
      () => _httpClient.post(
        _buildUri(path),
        headers: jsonHeaders,
        body: jsonEncode(body ?? const <String, Object?>{}),
      ),
    );
    return _decodeSuccess(response);
  }

  Uri _buildUri(String path, {Map<String, String>? queryParameters}) {
    final normalizedBasePath =
        _baseUri.path.endsWith('/')
            ? _baseUri.path.substring(0, _baseUri.path.length - 1)
            : _baseUri.path;
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    return _baseUri.replace(
      path: '$normalizedBasePath$normalizedPath',
      queryParameters: queryParameters,
    );
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          statusCode: response.statusCode,
          message: _errorMessage(response),
          body: response.body,
        );
      }
      return response;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const NetworkException(message: 'Tiempo de espera agotado.');
    } on SocketException {
      throw const NetworkException(message: 'No se pudo conectar al servidor.');
    } on http.ClientException catch (error) {
      throw NetworkException(message: error.message);
    }
  }

  Object? _decodeSuccess(http.Response response) {
    if (response.body.trim().isEmpty) {
      return null;
    }

    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Respuesta invalida del servidor.',
        body: response.body,
      );
    }
  }

  String _errorMessage(http.Response response) {
    if (response.body.trim().isEmpty) {
      return 'Error HTTP ${response.statusCode}.';
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, Object?>) {
        final detail = decoded['detail'];
        if (detail is String && detail.trim().isNotEmpty) {
          return detail;
        }
      }
    } on FormatException {
      return 'Error HTTP ${response.statusCode}.';
    }

    return 'Error HTTP ${response.statusCode}.';
  }
}
