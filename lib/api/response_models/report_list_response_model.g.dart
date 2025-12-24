// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_list_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportListResponseModel _$ReportListResponseModelFromJson(
        Map<String, dynamic> json) =>
    ReportListResponseModel(
      name: json['name'] as String,
      currentValue: (json['current_value'] as num).toDouble(),
      id: (json['id'] as num).toInt(),
      oldValue: (json['old_value'] as num).toDouble(),
    );

Map<String, dynamic> _$ReportListResponseModelToJson(
        ReportListResponseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'current_value': instance.currentValue,
      'old_value': instance.oldValue,
    };
