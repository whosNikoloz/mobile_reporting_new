import 'package:json_annotation/json_annotation.dart';

part 'report_group_response_model.g.dart';

@JsonSerializable()
class ReportGroupResponseModel {
  @JsonKey(name: 'tag')
  final String tag;

  @JsonKey(name: 'type')
  final String type;

  @JsonKey(name: 'name')
  final String name;

  ReportGroupResponseModel({
    required this.name,
    required this.tag,
    required this.type,
  });

  factory ReportGroupResponseModel.fromJson(Map<String, dynamic> json) => _$ReportGroupResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReportGroupResponseModelToJson(this);
}
