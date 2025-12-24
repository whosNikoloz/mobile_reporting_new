import 'package:json_annotation/json_annotation.dart';

part 'report_groups_request_model.g.dart';

@JsonSerializable()
class ReportGroupsRequestModel {
  @JsonKey(name: 'group_tag')
  final String groupTag;

  @JsonKey(name: 'lang')
  final String language;

  ReportGroupsRequestModel({
    required this.groupTag,
    required this.language,
  });

  factory ReportGroupsRequestModel.fromJson(Map<String, dynamic> json) => _$ReportGroupsRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReportGroupsRequestModelToJson(this);
}
