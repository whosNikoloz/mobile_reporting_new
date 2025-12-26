import 'dart:convert';
import 'package:mobile_reporting/api/request_models/dashboard_request_model.dart';
import 'package:mobile_reporting/api/response_models/dashboard_response_model.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/http_helper.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';

class ReportsService {
  final HttpHelper _httpHelper = HttpHelper();

  Future<String> _getServerUrl() async {
    final url = await getIt<PreferencesHelper>().getUrl() ?? '';
    return url
        .replaceAll('http://', '')
        .replaceAll('https://', '')
        .replaceAll(RegExp(r'/$'), '');
  }

  /// Unified dashboard API - returns all data in one call
  /// This replaces the old multi-call approach with a single efficient request
  Future<DashboardResponse?> getDashboardData({
    required int storeId,
    required DateTime startCurrentPeriod,
    required DateTime endCurrentPeriod,
    required DateTime startOldPeriod,
    required DateTime endOldPeriod,
    int paramId2 = 0,
  }) async {
    try {
      final requestBody = DashboardRequest(
        paramId: storeId,
        paramId2: paramId2,
        startCurrentPeriod: startCurrentPeriod,
        endCurrentPeriod: endCurrentPeriod,
        startOldPeriod: startOldPeriod,
        endOldPeriod: endOldPeriod,
      );

      final serverUrl = await _getServerUrl();
      final ck = await getIt<PreferencesHelper>().getDatabase();
      if (ck == null) {
        print('Database connection key is null');
        return null;
      }

      final response = await _httpHelper.fetchPost(
        ck,
        serverUrl,
        'get_dashboard_data',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final data = json.decode(response);
        return DashboardResponse.fromJson(data);
      }

      return null;
    } catch (err) {
      return null;
    }
  }
}
