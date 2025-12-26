import 'package:json_annotation/json_annotation.dart';

part 'hourly_sales_request_model.g.dart';

@JsonSerializable()
class HourlySalesRequestModel {
  @JsonKey(name: 'param_id')
  final int paramId;

  @JsonKey(name: 'start_date')
  final DateTime startDate;

  @JsonKey(name: 'end_date')
  final DateTime endDate;

  HourlySalesRequestModel({
    required this.paramId,
    required this.startDate,
    required this.endDate,
  });

  factory HourlySalesRequestModel.fromJson(Map<String, dynamic> json) =>
      _$HourlySalesRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$HourlySalesRequestModelToJson(this);
}
