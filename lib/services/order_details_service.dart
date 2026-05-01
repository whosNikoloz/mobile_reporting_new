import 'dart:convert';

import 'package:mobile_reporting/api/request_models/order_details_request_model.dart';
import 'package:mobile_reporting/api/response_models/order_details_response_model.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/http_helper.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';

import 'package:mobile_reporting/enums/business_type.dart';
import 'package:mobile_reporting/application_store.dart';

class OrderDetailsService {
  final HttpHelper _httpHelper = HttpHelper();

  Future<String> _getServerUrl() async {
    final url = await getIt<PreferencesHelper>().getUrl() ?? '';
    return url
        .replaceAll('http://', '')
        .replaceAll('https://', '')
        .replaceAll(RegExp(r'/$'), '');
  }

  Future<OrderDetailsResponseModel?> getOrderDetails({
    required int orderId,
  }) async {
    try {
      final businessType = (application.isRetail ?? false)
          ? BusinessType.retail
          : BusinessType.cafe;

      final requestBody = OrderDetailsRequestModel(
        orderId: orderId,
        businessType: businessType,
      );

      final serverUrl = await _getServerUrl();
      final ck = await getIt<PreferencesHelper>().getDatabase();
      if (ck == null) return null;

      final response = await _httpHelper.fetchPost(
        ck,
        serverUrl,
        'get_order_details',
        body: requestBody.toJson(),
      );

      if (response != null) {
        final Map<String, dynamic> data = json.decode(response);
        return OrderDetailsResponseModel.fromJson(data);
      }

      return null;
    } catch (err) {
      print('Error in getOrderDetails: $err');
      return null;
    }
  }
}
