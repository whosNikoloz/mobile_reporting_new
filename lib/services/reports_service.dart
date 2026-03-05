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
import 'package:mobile_reporting/api/request_models/profit_by_products_request_model.dart';
import 'package:mobile_reporting/api/request_models/profit_by_categories_request_model.dart';
import 'package:mobile_reporting/api/request_models/vendor_payments_request_model.dart';
import 'package:mobile_reporting/api/request_models/buyers_debt_request_model.dart';
import 'package:mobile_reporting/api/request_models/suppliers_debt_request_model.dart';
import 'package:mobile_reporting/api/response_models/order_response_model.dart';
import 'package:mobile_reporting/api/response_models/paged_response_model.dart';
import 'package:mobile_reporting/api/response_models/profit_by_product_response_model.dart';
import 'package:mobile_reporting/api/response_models/profit_by_category_response_model.dart';
import 'package:mobile_reporting/api/response_models/vendor_payments_response_model.dart';
import 'package:mobile_reporting/api/response_models/buyers_debt_response_model.dart';
import 'package:mobile_reporting/api/response_models/suppliers_debt_response_model.dart';
import 'package:mobile_reporting/api/request_models/product_rest_request_model.dart';
import 'package:mobile_reporting/api/response_models/product_rest_response_model.dart';
import 'package:mobile_reporting/api/request_models/contragent_payments_request_model.dart';
import 'package:mobile_reporting/api/response_models/contragent_payments_response_model.dart';
import 'package:mobile_reporting/api/request_models/product_sales_summary_request_model.dart';
import 'package:mobile_reporting/api/response_models/product_sales_summary_response_model.dart';
import 'package:mobile_reporting/api/request_models/product_sales_details_request_model.dart';
import 'package:mobile_reporting/api/response_models/product_sales_details_response_model.dart';
import 'package:mobile_reporting/api/request_models/store_transfer_details_request_model.dart';
import 'package:mobile_reporting/api/response_models/store_transfer_details_response_model.dart';
import 'package:mobile_reporting/api/request_models/sale_documents_request_model.dart';
import 'package:mobile_reporting/api/response_models/sale_documents_response_model.dart';
import 'package:mobile_reporting/api/request_models/sale_documents_products_summary_request_model.dart';
import 'package:mobile_reporting/api/response_models/sale_documents_products_summary_response_model.dart';
import 'package:mobile_reporting/api/request_models/sale_documents_products_details_request_model.dart';
import 'package:mobile_reporting/api/response_models/sale_documents_products_details_response_model.dart';
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
        return data
            .map((e) => TopProductSalesResponseModel.fromJson(e))
            .toList();
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
        return data
            .map((e) => PaymentEntitiesResponseModel.fromJson(e))
            .toList();
      }

      return null;
    } catch (err) {
      print('❌ Error in getPaymentEntitiesReport: $err');
      return null;
    }
  }

  /// Get profit by products report with pagination
  Future<List<ProfitByProductResponseModel>?> getProfitByProducts({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final requestBody = ProfitByProductsRequestModel(
        startDate: startDate,
        endDate: endDate,
        page: page,
        pageSize: pageSize,
      );

      final serverUrl = await _getServerUrl();
      final ck = await getIt<PreferencesHelper>().getDatabase();
      if (ck == null) return null;

      final response = await _httpHelper.fetchPost(
        ck,
        serverUrl,
        'get_profit_by_products',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final List<dynamic> data = json.decode(response);
        return data
            .map((e) => ProfitByProductResponseModel.fromJson(e))
            .toList();
      }

      return null;
    } catch (err) {
      print('❌ Error in getProfitByProducts: $err');
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

  /// Get buyers debt (accounts receivable) report with pagination
  Future<List<BuyersDebtResponseModel>?> getBuyersDebt({
    required DateTime beforeDate,
    String pathFrom = '0#2#5',
    String pathTo = '0#2#5%',
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final requestBody = BuyersDebtRequestModel(
        beforeDate: beforeDate,
        pathFrom: pathFrom,
        pathTo: pathTo,
        page: page,
        pageSize: pageSize,
      );

      final serverUrl = await _getServerUrl();
      final ck = await getIt<PreferencesHelper>().getDatabase();
      if (ck == null) return null;

      final response = await _httpHelper.fetchPost(
        ck,
        serverUrl,
        'get_buyers_debt',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final List<dynamic> data = json.decode(response);
        return data.map((e) => BuyersDebtResponseModel.fromJson(e)).toList();
      }

      return null;
    } catch (err) {
      print('âŒ Error in getBuyersDebt: $err');
      return null;
    }
  }

  /// Get suppliers debt (accounts payable) report with pagination
  Future<List<SuppliersDebtResponseModel>?> getSuppliersDebt({
    required DateTime beforeDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final requestBody = SuppliersDebtRequestModel(
        beforeDate: beforeDate,
        page: page,
        pageSize: pageSize,
      );

      final serverUrl = await _getServerUrl();
      final ck = await getIt<PreferencesHelper>().getDatabase();
      if (ck == null) return null;

      final response = await _httpHelper.fetchPost(
        ck,
        serverUrl,
        'get_suppliers_debt',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final List<dynamic> data = json.decode(response);
        return data.map((e) => SuppliersDebtResponseModel.fromJson(e)).toList();
      }

      return null;
    } catch (err) {
      print('❌ Error in getSuppliersDebt: $err');
      return null;
    }
  }

  /// Get profit by categories report with pagination
  Future<List<ProfitByCategoryResponseModel>?> getProfitByCategories({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final requestBody = ProfitByCategoriesRequestModel(
        startDate: startDate,
        endDate: endDate,
        page: page,
        pageSize: pageSize,
      );

      final serverUrl = await _getServerUrl();
      final ck = await getIt<PreferencesHelper>().getDatabase();
      if (ck == null) return null;

      final response = await _httpHelper.fetchPost(
        ck,
        serverUrl,
        'get_profit_by_categories',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final List<dynamic> data = json.decode(response);
        return data
            .map((e) => ProfitByCategoryResponseModel.fromJson(e))
            .toList();
      }

      return null;
    } catch (err) {
      print('❌ Error in getProfitByCategories: $err');
      return null;
    }
  }

  /// Get vendor payments report with pagination
  Future<List<VendorPaymentsResponseModel>?> getVendorPayments({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final requestBody = VendorPaymentsRequestModel(
        startDate: startDate,
        endDate: endDate,
        page: page,
        pageSize: pageSize,
      );

      final serverUrl = await _getServerUrl();
      final ck = await getIt<PreferencesHelper>().getDatabase();
      if (ck == null) return null;

      final response = await _httpHelper.fetchPost(
        ck,
        serverUrl,
        'get_vendor_payments',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final List<dynamic> data = json.decode(response);
        return data
            .map((e) => VendorPaymentsResponseModel.fromJson(e))
            .toList();
      }

      return null;
    } catch (err) {
      print('âŒ Error in getVendorPayments: $err');
      return null;
    }
  }

  /// Get vendor purchases report with pagination
  Future<List<VendorPaymentsResponseModel>?> getVendorPurchases({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final requestBody = VendorPaymentsRequestModel(
        startDate: startDate,
        endDate: endDate,
        page: page,
        pageSize: pageSize,
      );

      final serverUrl = await _getServerUrl();
      final ck = await getIt<PreferencesHelper>().getDatabase();
      if (ck == null) return null;

      final response = await _httpHelper.fetchPost(
        ck,
        serverUrl,
        'get_vendor_purchases',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final List<dynamic> data = json.decode(response);
        return data
            .map((e) => VendorPaymentsResponseModel.fromJson(e))
            .toList();
      }

      return null;
    } catch (err) {
      print('❌ Error in getVendorPurchases: $err');
      return null;
    }
  }

  /// Get customer sales report with pagination
  Future<List<VendorPaymentsResponseModel>?> getCustomerSales({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final requestBody = VendorPaymentsRequestModel(
        startDate: startDate,
        endDate: endDate,
        page: page,
        pageSize: pageSize,
      );

      final serverUrl = await _getServerUrl();
      final ck = await getIt<PreferencesHelper>().getDatabase();
      if (ck == null) return null;

      final response = await _httpHelper.fetchPost(
        ck,
        serverUrl,
        'get_customer_sales',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final List<dynamic> data = json.decode(response);
        return data
            .map((e) => VendorPaymentsResponseModel.fromJson(e))
            .toList();
      }

      return null;
    } catch (err) {
      print('❌ Error in getCustomerSales: $err');
      return null;
    }
  }

  /// Get customer returns report with pagination
  Future<List<VendorPaymentsResponseModel>?> getCustomerReturns({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final requestBody = VendorPaymentsRequestModel(
        startDate: startDate,
        endDate: endDate,
        page: page,
        pageSize: pageSize,
      );

      final serverUrl = await _getServerUrl();
      final ck = await getIt<PreferencesHelper>().getDatabase();
      if (ck == null) return null;

      final response = await _httpHelper.fetchPost(
        ck,
        serverUrl,
        'get_customer_returns',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final List<dynamic> data = json.decode(response);
        return data
            .map((e) => VendorPaymentsResponseModel.fromJson(e))
            .toList();
      }

      return null;
    } catch (err) {
      print('❌ Error in getCustomerReturns: $err');
      return null;
    }
  }

  /// Get customer payments report with pagination
  Future<List<VendorPaymentsResponseModel>?> getCustomerPayments({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final requestBody = VendorPaymentsRequestModel(
        startDate: startDate,
        endDate: endDate,
        page: page,
        pageSize: pageSize,
      );

      final serverUrl = await _getServerUrl();
      final ck = await getIt<PreferencesHelper>().getDatabase();
      if (ck == null) return null;

      final response = await _httpHelper.fetchPost(
        ck,
        serverUrl,
        'get_customer_payments',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final List<dynamic> data = json.decode(response);
        return data
            .map((e) => VendorPaymentsResponseModel.fromJson(e))
            .toList();
      }

      return null;
    } catch (err) {
      print('❌ Error in getCustomerPayments: $err');
      return null;
    }
  }

  /// Get vendor returns report with pagination
  Future<List<VendorPaymentsResponseModel>?> getVendorReturns({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final requestBody = VendorPaymentsRequestModel(
        startDate: startDate,
        endDate: endDate,
        page: page,
        pageSize: pageSize,
      );

      final serverUrl = await _getServerUrl();
      final ck = await getIt<PreferencesHelper>().getDatabase();
      if (ck == null) return null;

      final response = await _httpHelper.fetchPost(
        ck,
        serverUrl,
        'get_vendor_returns',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final List<dynamic> data = json.decode(response);
        return data
            .map((e) => VendorPaymentsResponseModel.fromJson(e))
            .toList();
      }

      return null;
    } catch (err) {
      print('❌ Error in getVendorReturns: $err');
      return null;
    }
  }

  /// Get inventory balance
  Future<List<ProductRestResponseModel>?> getInventoryBalance({
    required DateTime asOfDate,
    int storeId = 0,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final requestBody = ProductRestRequestModel(
        asOfDate: asOfDate,
        storeId: storeId,
        page: page,
        pageSize: pageSize,
      );

      final serverUrl = await _getServerUrl();
      final ck = await getIt<PreferencesHelper>().getDatabase();
      if (ck == null) return null;

      final response = await _httpHelper.fetchPost(
        ck,
        serverUrl,
        'get_inventory_balance',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final List<dynamic> data = json.decode(response);
        return data.map((e) => ProductRestResponseModel.fromJson(e)).toList();
      }

      return null;
    } catch (err) {
      print('❌ Error in getInventoryBalance: $err');
      return null;
    }
  }

  /// Get purchase documents
  Future<List<ContragentPaymentsResponseModel>?> getPurchaseDocuments({
    required DateTime startDate,
    required DateTime endDate,
    int storeId = 0,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final requestBody = ContragentPaymentsRequestModel(
        startDate: startDate,
        endDate: endDate,
        storeId: storeId,
        page: page,
        pageSize: pageSize,
      );

      final serverUrl = await _getServerUrl();
      final ck = await getIt<PreferencesHelper>().getDatabase();
      if (ck == null) return null;

      final response = await _httpHelper.fetchPost(
        ck,
        serverUrl,
        'get_purchase_documents',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final List<dynamic> data = json.decode(response);
        return data.map((e) => ContragentPaymentsResponseModel.fromJson(e)).toList();
      }

      return null;
    } catch (err) {
      print('❌ Error in getPurchaseDocuments: $err');
      return null;
    }
  }

  /// Get product sales summary (Purchases by item summary)
  Future<List<ProductSalesSummaryResponseModel>?> getProductSalesSummary({
    required DateTime startDate,
    required DateTime endDate,
    int storeId = 0,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final requestBody = ProductSalesSummaryRequestModel(
        startDate: startDate,
        endDate: endDate,
        storeId: storeId,
        page: page,
        pageSize: pageSize,
      );

      final serverUrl = await _getServerUrl();
      final ck = await getIt<PreferencesHelper>().getDatabase();
      if (ck == null) return null;

      final response = await _httpHelper.fetchPost(
        ck,
        serverUrl,
        'get_product_sales_summary',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final List<dynamic> data = json.decode(response);
        return data.map((e) => ProductSalesSummaryResponseModel.fromJson(e)).toList();
      }

      return null;
    } catch (err) {
      print('❌ Error in getProductSalesSummary: $err');
      return null;
    }
  }

  /// Get product sales details (Purchases by item detailed)
  Future<List<ProductSalesDetailsResponseModel>?> getProductSalesDetails({
    required DateTime startDate,
    required DateTime endDate,
    int storeId = 0,
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      final requestBody = ProductSalesDetailsRequestModel(
        startDate: startDate,
        endDate: endDate,
        storeId: storeId,
        page: page,
        pageSize: pageSize,
      );

      final serverUrl = await _getServerUrl();
      final ck = await getIt<PreferencesHelper>().getDatabase();
      if (ck == null) return null;

      final response = await _httpHelper.fetchPost(
        ck,
        serverUrl,
        'get_product_sales_details',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final List<dynamic> data = json.decode(response);
        return data.map((e) => ProductSalesDetailsResponseModel.fromJson(e)).toList();
      }

      return null;
    } catch (err) {
      print('❌ Error in getProductSalesDetails: $err');
      return null;
    }
  }

  /// Get store transfer details
  Future<List<StoreTransferDetailsResponseModel>?> getStoreTransferDetails({
    required DateTime startDate,
    required DateTime endDate,
    int fromStoreId = 0,
    int toStoreId = 0,
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      final requestBody = StoreTransferDetailsRequestModel(
        startDate: startDate,
        endDate: endDate,
        fromStoreId: fromStoreId,
        toStoreId: toStoreId,
        page: page,
        pageSize: pageSize,
      );

      final serverUrl = await _getServerUrl();
      final ck = await getIt<PreferencesHelper>().getDatabase();
      if (ck == null) return null;

      final response = await _httpHelper.fetchPost(
        ck,
        serverUrl,
        'get_store_transfer_details',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final List<dynamic> data = json.decode(response);
        return data.map((e) => StoreTransferDetailsResponseModel.fromJson(e)).toList();
      }

      return null;
    } catch (err) {
      print('❌ Error in getStoreTransferDetails: $err');
      return null;
    }
  }

  /// Get sale documents
  Future<List<SaleDocumentsResponseModel>?> getSaleDocuments({
    required DateTime startDate,
    required DateTime endDate,
    int storeId = 0,
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      final requestBody = SaleDocumentsRequestModel(
        startDate: startDate,
        endDate: endDate,
        storeId: storeId,
        page: page,
        pageSize: pageSize,
      );

      final serverUrl = await _getServerUrl();
      final ck = await getIt<PreferencesHelper>().getDatabase();
      if (ck == null) return null;

      final response = await _httpHelper.fetchPost(
        ck,
        serverUrl,
        'get_sale_documents',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final List<dynamic> data = json.decode(response);
        return data.map((e) => SaleDocumentsResponseModel.fromJson(e)).toList();
      }

      return null;
    } catch (err) {
      print('❌ Error in getSaleDocuments: $err');
      return null;
    }
  }

  /// Get sale documents products summary
  Future<List<SaleDocumentsProductsSummaryResponseModel>?> getSaleDocumentsProductsSummary({
    required DateTime startDate,
    required DateTime endDate,
    int storeId = 0,
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      final requestBody = SaleDocumentsProductsSummaryRequestModel(
        startDate: startDate,
        endDate: endDate,
        storeId: storeId,
        page: page,
        pageSize: pageSize,
      );

      final serverUrl = await _getServerUrl();
      final ck = await getIt<PreferencesHelper>().getDatabase();
      if (ck == null) return null;

      final response = await _httpHelper.fetchPost(
        ck,
        serverUrl,
        'get_sale_documents_products_summary',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final List<dynamic> data = json.decode(response);
        return data.map((e) => SaleDocumentsProductsSummaryResponseModel.fromJson(e)).toList();
      }

      return null;
    } catch (err) {
      print('❌ Error in getSaleDocumentsProductsSummary: $err');
      return null;
    }
  }

  /// Get sale documents products details
  Future<List<SaleDocumentsProductsDetailsResponseModel>?> getSaleDocumentsProductsDetails({
    required DateTime startDate,
    required DateTime endDate,
    int storeId = 0,
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      final requestBody = SaleDocumentsProductsDetailsRequestModel(
        startDate: startDate,
        endDate: endDate,
        storeId: storeId,
        page: page,
        pageSize: pageSize,
      );

      final serverUrl = await _getServerUrl();
      final ck = await getIt<PreferencesHelper>().getDatabase();
      if (ck == null) return null;

      final response = await _httpHelper.fetchPost(
        ck,
        serverUrl,
        'get_sale_documents_products_details',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final List<dynamic> data = json.decode(response);
        return data.map((e) => SaleDocumentsProductsDetailsResponseModel.fromJson(e)).toList();
      }

      return null;
    } catch (err) {
      print('❌ Error in getSaleDocumentsProductsDetails: $err');
      return null;
    }
  }
}
