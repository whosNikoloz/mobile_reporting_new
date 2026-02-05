import 'package:json_annotation/json_annotation.dart';

part 'top_products_request_model.g.dart';

@JsonSerializable()
class TopProductsRequestModel {
  @JsonKey(name: "param_id")
  int paramId;

  @JsonKey(name: "top")
  int top;

  @JsonKey(name: "start_current_period")
  DateTime startCurrentPeriod;

  @JsonKey(name: "end_current_period")
  DateTime endCurrentPeriod;

  @JsonKey(name: "start_previous_period")
  DateTime startPreviousPeriod;

  @JsonKey(name: "end_previous_period")
  DateTime endPreviousPeriod;

  TopProductsRequestModel({
    this.paramId = 0,
    this.top = 10,
    required this.startCurrentPeriod,
    required this.endCurrentPeriod,
    required this.startPreviousPeriod,
    required this.endPreviousPeriod,
  });

  factory TopProductsRequestModel.fromJson(Map<String, dynamic> json) =>
      _$TopProductsRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$TopProductsRequestModelToJson(this);
}
