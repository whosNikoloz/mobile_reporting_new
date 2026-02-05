import 'package:json_annotation/json_annotation.dart';

part 'staff_sales_request_model.g.dart';

@JsonSerializable()
class StaffSalesRequestModel {
  @JsonKey(name: 'store_id')
  final int storeId;

  @JsonKey(name: 'top')
  final int top;

  @JsonKey(name: 'start_previous_period')
  final DateTime startPreviousPeriod;

  @JsonKey(name: 'end_previous_period')
  final DateTime endPreviousPeriod;

  @JsonKey(name: 'start_current_period')
  final DateTime startCurrentPeriod;

  @JsonKey(name: 'end_current_period')
  final DateTime endCurrentPeriod;

  StaffSalesRequestModel({
    this.storeId = 0,
    this.top = 0,
    required this.startPreviousPeriod,
    required this.endPreviousPeriod,
    required this.startCurrentPeriod,
    required this.endCurrentPeriod,
  });

  factory StaffSalesRequestModel.fromJson(Map<String, dynamic> json) =>
      _$StaffSalesRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$StaffSalesRequestModelToJson(this);
}
