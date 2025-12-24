import 'package:dio/dio.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';

class ApiService {
  final Dio _dio = Dio();
  static const String _secureKey = 'UNp5LsjzQ1wqO6TdYaDFeB8M7fmh35Uk';

  Future<Options> _getOptions({bool includeAuth = true}) async {
    final headers = <String, dynamic>{
      'SecureKey': _secureKey,
    };

    if (includeAuth) {
      final authToken = await getIt<PreferencesHelper>().getUserAuthToken();
      if (authToken != null) {
        headers['Authorization'] = 'Bearer $authToken';
      }
    }

    return Options(
      contentType: 'application/json',
      headers: headers,
      validateStatus: (status) => true,
    );
  }

  Future<String> _getBaseUrl() async {
    return await getIt<PreferencesHelper>().getUrl() ?? '';
  }

  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool includeAuth = true,
  }) async {
    final baseUrl = await _getBaseUrl();
    final options = await _getOptions(includeAuth: includeAuth);

    return await _dio.get(
      '$baseUrl$endpoint',
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post(
    String endpoint, {
    dynamic data,
    bool includeAuth = true,
  }) async {
    final baseUrl = await _getBaseUrl();
    final options = await _getOptions(includeAuth: includeAuth);

    return await _dio.post(
      '$baseUrl$endpoint',
      data: data,
      options: options,
    );
  }

  Future<Response> postExternal(
    String url, {
    dynamic data,
    Map<String, dynamic>? headers,
  }) async {
    return await _dio.post(
      url,
      data: data,
      options: Options(
        contentType: 'application/json',
        headers: headers,
        validateStatus: (status) => true,
      ),
    );
  }
}
