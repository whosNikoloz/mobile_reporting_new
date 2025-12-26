// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hourly_sales_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HourlySalesRequestModel _$HourlySalesRequestModelFromJson(
        Map<String, dynamic> json) =>
    HourlySalesRequestModel(
      paramId: (json['param_id'] as num).toInt(),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
    );

Map<String, dynamic> _$HourlySalesRequestModelToJson(
        HourlySalesRequestModel instance) =>
    <String, dynamic>{
      'param_id': instance.paramId,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate.toIso8601String(),
    };
