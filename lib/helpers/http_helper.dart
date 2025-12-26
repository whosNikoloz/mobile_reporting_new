import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpHelper {
  final _secureKey = 'UNp5LsjzQ1wqO6TdYaDFeB8M7fmh35Uk';

  Future<String?> fetchGet(
    String ck,
    String serverUrl,
    String method, {
    Map<String, dynamic>? params,
  }) async {
    final uri = Uri.http(serverUrl, '/api/report/$method', params);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'SecureKey': _secureKey,
        'ck': ck,
      },
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  Future<String?> fetchPost(
    String ck,
    String serverUrl,
    String method, {
    dynamic body,
  }) async {
    final requestBody = json.encode(body);
    final uri = Uri.http(serverUrl, '/api/report/$method');

    final response = await http.post(
      uri,
      body: requestBody,
      headers: {
        'Content-Type': 'application/json',
        'SecureKey': _secureKey,
        'ck': ck,
      },
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  Future<http.Response> postExternal(
    String url, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final requestBody = json.encode(body);
    final uri = Uri.parse(url);

    return await http.post(
      uri,
      body: requestBody,
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
    );
  }
}
