import 'dart:convert';
import 'package:mobile_reporting/api/request_models/dashboard_request_model.dart';
import 'package:mobile_reporting/api/response_models/dashboard_response_model.dart';
import 'package:mobile_reporting/api/response_models/daily_sales_response_model.dart';
import 'package:mobile_reporting/api/response_models/hourly_sales_response_model.dart';
import 'package:mobile_reporting/api/response_models/weekday_sales_response_model.dart';
import 'package:mobile_reporting/api/response_models/store_sales_response_model.dart';
import 'package:mobile_reporting/api/request_models/top_products_request_model.dart';
import 'package:mobile_reporting/api/response_models/top_product_sales_response_model.dart';
import 'package:mobile_reporting/api/request_models/top_category_request_model.dart';
import 'package:mobile_reporting/api/response_models/category_sales_response_model.dart';
import 'package:mobile_reporting/api/request_models/staff_sales_request_model.dart';
import 'package:mobile_reporting/api/response_models/staff_sales_response_model.dart';
import 'package:mobile_reporting/api/request_models/payment_entities_request_model.dart';
import 'package:mobile_reporting/api/response_models/payment_entities_response_model.dart';
import 'package:mobile_reporting/api/request_models/orders_request_model.dart';
import 'package:mobile_reporting/api/response_models/order_response_model.dart';
import 'package:mobile_reporting/api/response_models/paged_response_model.dart';
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

  /// Get store sales report
  Future<List<StoreSalesResponseModel>?> getStoreSalesReport({
    required DateTime startCurrentPeriod,
    required DateTime endCurrentPeriod,
    required DateTime startPreviousPeriod,
    required DateTime endPreviousPeriod,
  }) async {
    try {
      final requestBody = DashboardRequest(
        paramId: 0, // 0 means all stores
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
        'get_store_sales_report',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final List<dynamic> data = json.decode(response);
        return data.map((e) => StoreSalesResponseModel.fromJson(e)).toList();
      }

      return null;
    } catch (err) {
      print('❌ Error in getStoreSalesReport: $err');
      return null;
    }
  }
  /// Get top products report
  Future<List<TopProductSalesResponseModel>?> getTopProductsReport({
    required int storeId,
    required int top,
    required DateTime startCurrentPeriod,
    required DateTime endCurrentPeriod,
    required DateTime startPreviousPeriod,
    required DateTime endPreviousPeriod,
  }) async {
    try {
      final requestBody = TopProductsRequestModel(
        paramId: storeId,
        top: top,
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
        'get_top_products_report',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final List<dynamic> data = json.decode(response);
        return data.map((e) => TopProductSalesResponseModel.fromJson(e)).toList();
      }

      return null;
    } catch (err) {
      print('❌ Error in getTopProductsReport: $err');
      return null;
    }
  }


  /// Get category sales report
  Future<List<CategorySalesResponseModel>?> getCategorySalesReport({
    required int storeId,
    required int top,
    required DateTime startCurrentPeriod,
    required DateTime endCurrentPeriod,
    required DateTime startPreviousPeriod,
    required DateTime endPreviousPeriod,
  }) async {
    try {
      final requestBody = TopCategoryRequestModel(
        paramId: storeId,
        top: top,
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
        'get_category_sales_report',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final List<dynamic> data = json.decode(response);
        return data.map((e) => CategorySalesResponseModel.fromJson(e)).toList();
      }

      return null;
    } catch (err) {
      print('❌ Error in getCategorySalesReport: $err');
      return null;
    }

  }

  /// Get staff sales report
  Future<List<StaffSalesResponseModel>?> getStaffSalesReport({
    required int storeId,
    required int top,
    required DateTime startCurrentPeriod,
    required DateTime endCurrentPeriod,
    required DateTime startPreviousPeriod,
    required DateTime endPreviousPeriod,
  }) async {
    try {
      final requestBody = StaffSalesRequestModel(
        storeId: storeId,
        top: top,
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
        'get_staff_sales_report',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final List<dynamic> data = json.decode(response);
        return data.map((e) => StaffSalesResponseModel.fromJson(e)).toList();
      }

      return null;
    } catch (err) {
      print('❌ Error in getStaffSalesReport: $err');
      return null;
    }
  }

  /// Get payment entities report
  Future<List<PaymentEntitiesResponseModel>?> getPaymentEntitiesReport({
    required int storeId,
    required int top,
    required DateTime startCurrentPeriod,
    required DateTime endCurrentPeriod,
    required DateTime startPreviousPeriod,
    required DateTime endPreviousPeriod,
  }) async {
    try {
      final requestBody = PaymentEntitiesRequestModel(
        storeId: storeId,
        top: top,
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
        'get_payment_entities_report',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final List<dynamic> data = json.decode(response);
        return data.map((e) => PaymentEntitiesResponseModel.fromJson(e)).toList();
      }

      return null;
    } catch (err) {
      print('❌ Error in getPaymentEntitiesReport: $err');
      return null;
    }
  }

  /// Get orders with pagination
  Future<PagedResponse<OrderResponseModel>?> getOrders({
    required int storeId,
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
  }) async {
    try {
      final requestBody = OrdersRequestModel(
        storeId: storeId,
        startDate: startDate,
        endDate: endDate,
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
      );

      final serverUrl = await _getServerUrl();
      final ck = await getIt<PreferencesHelper>().getDatabase();
      if (ck == null) return null;

      final response = await _httpHelper.fetchPost(
        ck,
        serverUrl,
        'get_orders',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final Map<String, dynamic> data = json.decode(response);
        return PagedResponse<OrderResponseModel>.fromJson(
          data,
          (m) => OrderResponseModel.fromJson(m),
        );
      }

      return null;
    } catch (err) {
      print('❌ Error in getOrders: $err');
      return null;
    }
  }
}
