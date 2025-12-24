// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_groups_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportGroupsRequestModel _$ReportGroupsRequestModelFromJson(
        Map<String, dynamic> json) =>
    ReportGroupsRequestModel(
      groupTag: json['group_tag'] as String,
      language: json['lang'] as String,
    );

Map<String, dynamic> _$ReportGroupsRequestModelToJson(
        ReportGroupsRequestModel instance) =>
    <String, dynamic>{
      'group_tag': instance.groupTag,
      'lang': instance.language,
    };
