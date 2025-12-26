import 'package:json_annotation/json_annotation.dart';

part 'hourly_sales_response_model.g.dart';

@JsonSerializable()
class HourlySalesResponseModel {
  @JsonKey(name: 'time_range')
  final String timeRange;

  @JsonKey(name: 'value')
  final double value;

  HourlySalesResponseModel({
    required this.timeRange,
    required this.value,
  });

  factory HourlySalesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$HourlySalesResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$HourlySalesResponseModelToJson(this);
}
