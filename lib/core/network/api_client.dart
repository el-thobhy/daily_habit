import 'dart:convert';
import 'package:daily_habit/core/services/secure_storage_service.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final SecureStorageService secureStorage;
  final http.Client client;

  ApiClient({required this.secureStorage, http.Client? client})
      : client = client ?? http.Client();

  Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withAuth) {
      final token = await secureStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<http.Response> post(
    String url, {
    Object? body,
    bool withAuth = false,
  }) async {
    final headers = await _getHeaders(withAuth: withAuth);
    return await client.post(
      Uri.parse(url),
      headers: headers,
      body: body is Map || body is List ? jsonEncode(body) : body,
    );
  }

  Future<http.Response> get(
    String url, {
    bool withAuth = true,
  }) async {
    final headers = await _getHeaders(withAuth: withAuth);
    return await client.get(
      Uri.parse(url),
      headers: headers,
    );
  }
}
