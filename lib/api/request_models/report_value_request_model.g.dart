// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_value_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportValueRequestModel _$ReportValueRequestModelFromJson(
        Map<String, dynamic> json) =>
    ReportValueRequestModel(
      reportTag: json['report_tag'] as String,
      paramId: (json['param_id'] as num).toInt(),
      startCurrentPeriod:
          DateTime.parse(json['start_current_period'] as String),
      endCurrentPeriod: DateTime.parse(json['end_current_period'] as String),
      startOldPeriod: DateTime.parse(json['start_old_period'] as String),
      endOldPeriod: DateTime.parse(json['end_old_period'] as String),
      paramId2: (json['param_id2'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ReportValueRequestModelToJson(
        ReportValueRequestModel instance) =>
    <String, dynamic>{
      'report_tag': instance.reportTag,
      'param_id': instance.paramId,
      'param_id2': instance.paramId2,
      'start_current_period': instance.startCurrentPeriod.toIso8601String(),
      'end_current_period': instance.endCurrentPeriod.toIso8601String(),
      'start_old_period': instance.startOldPeriod.toIso8601String(),
      'end_old_period': instance.endOldPeriod.toIso8601String(),
    };
