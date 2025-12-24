import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_reporting/api/response_models/payment_response_model.dart';
import 'package:mobile_reporting/api/response_models/products_flow_response_model.dart';

part 'bill_details_response_model.g.dart';

@JsonSerializable()
class BillDetailsResponseModel {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'products')
  final List<ProductsFlowResponseModel> products;

  @JsonKey(name: 'payments')
  final List<PaymentResponseModel> payments;

  BillDetailsResponseModel({
    required this.id,
    required this.payments,
    required this.products,
  });

  factory BillDetailsResponseModel.fromJson(Map<String, dynamic> json) => _$BillDetailsResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$BillDetailsResponseModelToJson(this);
}
