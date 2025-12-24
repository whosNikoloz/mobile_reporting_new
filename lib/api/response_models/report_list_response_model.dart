import 'package:json_annotation/json_annotation.dart';

part 'report_list_response_model.g.dart';

@JsonSerializable()
class ReportListResponseModel {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'current_value')
  final double currentValue;

  @JsonKey(name: 'old_value')
  final double oldValue;

  ReportListResponseModel({
    required this.name,
    required this.currentValue,
    required this.id,
    required this.oldValue,
  });

  factory ReportListResponseModel.fromJson(Map<String, dynamic> json) => _$ReportListResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReportListResponseModelToJson(this);
}
