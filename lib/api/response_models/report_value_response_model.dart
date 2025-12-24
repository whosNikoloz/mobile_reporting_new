import 'package:json_annotation/json_annotation.dart';

part 'report_value_response_model.g.dart';

@JsonSerializable()
class ReportValueResponseModel {
  @JsonKey(name: 'current_value')
  final double currentValue;

  @JsonKey(name: 'old_value')
  final double oldValue;

  ReportValueResponseModel({
    required this.currentValue,
    required this.oldValue,
  });

  factory ReportValueResponseModel.fromJson(Map<String, dynamic> json) => _$ReportValueResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReportValueResponseModelToJson(this);
}
