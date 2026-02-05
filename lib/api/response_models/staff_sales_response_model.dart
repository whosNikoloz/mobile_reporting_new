import 'package:json_annotation/json_annotation.dart';

part 'staff_sales_response_model.g.dart';

@JsonSerializable()
class StaffSalesResponseModel {
  @JsonKey(name: 'staff_id')
  final int staffId;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'previous_sales')
  final double previousSales;

  @JsonKey(name: 'previous_checks')
  final int previousChecks;

  @JsonKey(name: 'previous_avg_check')
  final double previousAvgCheck;

  @JsonKey(name: 'previous_sales_percent')
  final double previousSalesPercent;

  @JsonKey(name: 'current_sales')
  final double currentSales;

  @JsonKey(name: 'current_checks')
  final int currentChecks;

  @JsonKey(name: 'current_avg_check')
  final double currentAvgCheck;

  @JsonKey(name: 'current_sales_percent')
  final double currentSalesPercent;

  StaffSalesResponseModel({
    required this.staffId,
    required this.name,
    required this.previousSales,
    required this.previousChecks,
    required this.previousAvgCheck,
    required this.previousSalesPercent,
    required this.currentSales,
    required this.currentChecks,
    required this.currentAvgCheck,
    required this.currentSalesPercent,
  });

  factory StaffSalesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$StaffSalesResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$StaffSalesResponseModelToJson(this);
}
