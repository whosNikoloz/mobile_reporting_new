import 'package:json_annotation/json_annotation.dart';

part 'top_category_request_model.g.dart';

@JsonSerializable()
class TopCategoryRequestModel {
  @JsonKey(name: 'param_id')
  final int paramId;

  @JsonKey(name: 'top')
  final int top;

  @JsonKey(name: 'start_current_period')
  final DateTime startCurrentPeriod;

  @JsonKey(name: 'end_current_period')
  final DateTime endCurrentPeriod;

  @JsonKey(name: 'start_previous_period')
  final DateTime startPreviousPeriod;

  @JsonKey(name: 'end_previous_period')
  final DateTime endPreviousPeriod;

  TopCategoryRequestModel({
    this.paramId = 0,
    this.top = 10,
    required this.startCurrentPeriod,
    required this.endCurrentPeriod,
    required this.startPreviousPeriod,
    required this.endPreviousPeriod,
  });

  factory TopCategoryRequestModel.fromJson(Map<String, dynamic> json) =>
      _$TopCategoryRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$TopCategoryRequestModelToJson(this);
}
