import 'dart:convert';
import 'package:mobile_reporting/api/request_models/dashboard_request_model.dart';
import 'package:mobile_reporting/api/response_models/dashboard_response_model.dart';
import 'package:mobile_reporting/api/response_models/daily_sales_response_model.dart';
import 'package:mobile_reporting/api/response_models/hourly_sales_response_model.dart';
import 'package:mobile_reporting/api/response_models/weekday_sales_response_model.dart';
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
    required DateTime startPreviousPeriod,
    required DateTime endPreviousPeriod,
  }) async {
    try {
      final requestBody = DashboardRequest(
        paramId: storeId,
        startCurrentPeriod: startCurrentPeriod,
        endCurrentPeriod: endCurrentPeriod,
        startPreviousPeriod: startPreviousPeriod,
        endPreviousPeriod: endPreviousPeriod,
      );

      // Debug logging
      print('📅 Dashboard API Request:');
      print(
          '  Current Period: ${startCurrentPeriod.toIso8601String()} to ${endCurrentPeriod.toIso8601String()}');
      print(
          '  Previous Period: ${startPreviousPeriod.toIso8601String()} to ${endPreviousPeriod.toIso8601String()}');
      print('  JSON: ${requestBody.toJson()}');

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
      print('❌ Error in getDashboardData: $err');
      return null;
    }
  }

  /// Get daily sales report
  Future<List<DailySalesResponseModel>?> getDailySalesReport({
    required int storeId,
    required DateTime startCurrentPeriod,
    required DateTime endCurrentPeriod,
    required DateTime startPreviousPeriod,
    required DateTime endPreviousPeriod,
  }) async {
    try {
      final requestBody = DashboardRequest(
        paramId: storeId,
        startCurrentPeriod: startCurrentPeriod,
        endCurrentPeriod: endCurrentPeriod,
        startPreviousPeriod: startPreviousPeriod,
        endPreviousPeriod: endPreviousPeriod,
      );

      final serverUrl = await _getServerUrl();
      final ck = await getIt<PreferencesHelper>().getDatabase();
      if (ck == null) return null;

      final response = await _httpHelper.fetchPost(
        ck,
        serverUrl,
        'get_daily_sales_report',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final List<dynamic> data = json.decode(response);
        return data.map((e) => DailySalesResponseModel.fromJson(e)).toList();
      }

      return null;
    } catch (err) {
      print('❌ Error in getDailySalesReport: $err');
      return null;
    }
  }

  /// Get hourly sales report
  Future<List<HourlySalesResponseModel>?> getHourlySalesReport({
    required int storeId,
    required DateTime startCurrentPeriod,
    required DateTime endCurrentPeriod,
    required DateTime startPreviousPeriod,
    required DateTime endPreviousPeriod,
  }) async {
    try {
      final requestBody = DashboardRequest(
        paramId: storeId,
        startCurrentPeriod: startCurrentPeriod,
        endCurrentPeriod: endCurrentPeriod,
        startPreviousPeriod: startPreviousPeriod,
        endPreviousPeriod: endPreviousPeriod,
      );

      final serverUrl = await _getServerUrl();
      final ck = await getIt<PreferencesHelper>().getDatabase();
      if (ck == null) return null;

      final response = await _httpHelper.fetchPost(
        ck,
        serverUrl,
        'get_hourly_sales_report',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final List<dynamic> data = json.decode(response);
        return data.map((e) => HourlySalesResponseModel.fromJson(e)).toList();
      }

      return null;
    } catch (err) {
      print('❌ Error in getHourlySalesReport: $err');
      return null;
    }
  }

  /// Get weekday sales report
  Future<List<WeekdaySalesResponseModel>?> getWeekdaySalesReport({
    required int storeId,
    required DateTime startCurrentPeriod,
    required DateTime endCurrentPeriod,
    required DateTime startPreviousPeriod,
    required DateTime endPreviousPeriod,
  }) async {
    try {
      final requestBody = DashboardRequest(
        paramId: storeId,
        startCurrentPeriod: startCurrentPeriod,
        endCurrentPeriod: endCurrentPeriod,
        startPreviousPeriod: startPreviousPeriod,
        endPreviousPeriod: endPreviousPeriod,
      );

      final serverUrl = await _getServerUrl();
      final ck = await getIt<PreferencesHelper>().getDatabase();
      if (ck == null) return null;

      final response = await _httpHelper.fetchPost(
        ck,
        serverUrl,
        'get_weekday_sales_report',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final List<dynamic> data = json.decode(response);
        return data.map((e) => WeekdaySalesResponseModel.fromJson(e)).toList();
      }

      return null;
    } catch (err) {
      print('❌ Error in getWeekdaySalesReport: $err');
      return null;
    }
  }
}
