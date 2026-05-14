import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'http://192.168.1.8:8000/api';

  final http.Client client;

  ApiClient({http.Client? client}) : client = client ?? http.Client();

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw ApiException(
      response.statusCode,
      response.body,
    );
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String body;

  ApiException(this.statusCode, this.body);

  @override
  String toString() => 'ApiException(statusCode: $statusCode, body: $body)';
}