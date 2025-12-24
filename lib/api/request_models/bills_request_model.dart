import 'package:json_annotation/json_annotation.dart';

part 'bills_request_model.g.dart';

@JsonSerializable()
class BillsRequestModel {
  @JsonKey(name: 'param_id')
  final int paramId;

  @JsonKey(name: 'start_date')
  final DateTime startDate;

  @JsonKey(name: 'endDate')
  final DateTime endDate;

  @JsonKey(name: 'start_amount')
  final double? minAmount;

  @JsonKey(name: 'end_amount')
  final double? maxAmount;

  @JsonKey(name: 'bill_num')
  final String? billNum;

  BillsRequestModel({
    required this.endDate,
    required this.paramId,
    required this.startDate,
    required this.billNum,
    required this.maxAmount,
    required this.minAmount,
  });

  factory BillsRequestModel.fromJson(Map<String, dynamic> json) => _$BillsRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$BillsRequestModelToJson(this);
}
