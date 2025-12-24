// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_value_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportValueResponseModel _$ReportValueResponseModelFromJson(
        Map<String, dynamic> json) =>
    ReportValueResponseModel(
      currentValue: (json['current_value'] as num).toDouble(),
      oldValue: (json['old_value'] as num).toDouble(),
    );

Map<String, dynamic> _$ReportValueResponseModelToJson(
        ReportValueResponseModel instance) =>
    <String, dynamic>{
      'current_value': instance.currentValue,
      'old_value': instance.oldValue,
    };
