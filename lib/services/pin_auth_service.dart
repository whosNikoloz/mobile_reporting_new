import 'dart:convert';

import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/http_helper.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';

class PinAuthService {
  final HttpHelper _httpHelper = HttpHelper();

  Future<PinAuthResult?> authenticatePin(String pin) async {
    try {
      final prefs = getIt<PreferencesHelper>();
      final rawUrl = await prefs.getUrl() ?? '';
      final ck = await prefs.getDatabase() ?? '';

      if (rawUrl.isEmpty || ck.isEmpty) {
        return null;
      }

      final serverUrl = rawUrl
          .replaceAll('http://', '')
          .replaceAll('https://', '')
          .replaceAll(RegExp(r'/$'), '');

      // NOTE: If backend expects a specific PinCodeWithCompany format,
      // adjust this mapping to match that logic.
      final body = <String, dynamic>{
        'pin_code': pin,
        'pin_code_with_company': pin,
      };

      final response =
          await _httpHelper.fetchPost(ck, serverUrl, 'auth_pin', body: body);
      if (response == null) return null;

      final decoded = json.decode(response) as Map<String, dynamic>;

      final dynamic errorRaw = decoded['Error'] ?? decoded['error'];
      final dynamic idRaw = decoded['Id'] ?? decoded['id'];
      final dynamic nameRaw = decoded['Name'] ?? decoded['name'];

      final int id = idRaw is int ? idRaw : int.tryParse('$idRaw') ?? 0;
      final int error =
          errorRaw is int ? errorRaw : int.tryParse('$errorRaw') ?? 0;
      final String name = nameRaw?.toString() ?? '';

      return PinAuthResult(
        id: id,
        name: name,
        hasError: error != 0 || id == 0,
      );
    } catch (_) {
      return null;
    }
  }
}

class PinAuthResult {
  final int id;
  final String name;
  final bool hasError;

  const PinAuthResult({
    required this.id,
    required this.name,
    required this.hasError,
  });
}
