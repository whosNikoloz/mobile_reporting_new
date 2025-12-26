// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hourly_sales_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HourlySalesResponseModel _$HourlySalesResponseModelFromJson(
        Map<String, dynamic> json) =>
    HourlySalesResponseModel(
      timeRange: json['time_range'] as String,
      value: (json['value'] as num).toDouble(),
    );

Map<String, dynamic> _$HourlySalesResponseModelToJson(
        HourlySalesResponseModel instance) =>
    <String, dynamic>{
      'time_range': instance.timeRange,
      'value': instance.value,
    };
