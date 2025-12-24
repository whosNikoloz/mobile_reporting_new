import 'package:json_annotation/json_annotation.dart';

part 'report_value_request_model.g.dart';

@JsonSerializable()
class ReportValueRequestModel {
  @JsonKey(name: 'report_tag')
  final String reportTag;

  @JsonKey(name: 'param_id')
  final int paramId;

  @JsonKey(name: 'param_id2')
  final int? paramId2;

  @JsonKey(name: 'start_current_period')
  final DateTime startCurrentPeriod;

  @JsonKey(name: 'end_current_period')
  final DateTime endCurrentPeriod;

  @JsonKey(name: 'start_old_period')
  final DateTime startOldPeriod;

  @JsonKey(name: 'end_old_period')
  final DateTime endOldPeriod;

  ReportValueRequestModel({
    required this.reportTag,
    required this.paramId,
    required this.startCurrentPeriod,
    required this.endCurrentPeriod,
    required this.startOldPeriod,
    required this.endOldPeriod,
    required this.paramId2,
  });

  factory ReportValueRequestModel.fromJson(Map<String, dynamic> json) => _$ReportValueRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReportValueRequestModelToJson(this);
}
