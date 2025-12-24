import 'dart:convert';
import 'package:mobile_reporting/api/request_models/bills_request_model.dart';
import 'package:mobile_reporting/api/response_models/bill_details_response_model.dart';
import 'package:mobile_reporting/api/response_models/bill_response_model.dart';
import 'package:mobile_reporting/services/api_service.dart';

class BillService {
  final ApiService _apiService = ApiService();

  Future<List<BillResponseModel>> getBills({
    required DateTime startDate,
    required DateTime endDate,
    double? minAmount,
    double? maxAmount,
    String? billNum,
  }) async {
    final requestModel = BillsRequestModel(
      endDate: endDate,
      paramId: 0,
      startDate: startDate,
      billNum: billNum,
      maxAmount: maxAmount,
      minAmount: minAmount,
    );

    final response = await _apiService.post(
      'api/report/get_bills',
      data: json.encode(requestModel),
    );

    if (response.statusCode == 200) {
      return List<BillResponseModel>.from(
        response.data.map(
          (e) => BillResponseModel.fromJson(e as Map<String, dynamic>),
        ),
      );
    }

    return [];
  }

  Future<BillDetailsResponseModel?> getBillDetails({required int billId}) async {
    final response = await _apiService.get(
      'api/report/get_bill_details',
      queryParameters: {'billId': billId},
    );

    if (response.statusCode == 200) {
      return BillDetailsResponseModel.fromJson(response.data);
    }

    return null;
  }
}
