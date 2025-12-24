// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_group_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportGroupResponseModel _$ReportGroupResponseModelFromJson(
        Map<String, dynamic> json) =>
    ReportGroupResponseModel(
      name: json['name'] as String,
      tag: json['tag'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$ReportGroupResponseModelToJson(
        ReportGroupResponseModel instance) =>
    <String, dynamic>{
      'tag': instance.tag,
      'type': instance.type,
      'name': instance.name,
    };
