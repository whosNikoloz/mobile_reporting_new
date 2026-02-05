// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_products_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopProductsRequestModel _$TopProductsRequestModelFromJson(
        Map<String, dynamic> json) =>
    TopProductsRequestModel(
      paramId: (json['param_id'] as num?)?.toInt() ?? 0,
      top: (json['top'] as num?)?.toInt() ?? 10,
      startCurrentPeriod:
          DateTime.parse(json['start_current_period'] as String),
      endCurrentPeriod: DateTime.parse(json['end_current_period'] as String),
      startPreviousPeriod:
          DateTime.parse(json['start_previous_period'] as String),
      endPreviousPeriod: DateTime.parse(json['end_previous_period'] as String),
    );

Map<String, dynamic> _$TopProductsRequestModelToJson(
        TopProductsRequestModel instance) =>
    <String, dynamic>{
      'param_id': instance.paramId,
      'top': instance.top,
      'start_current_period': instance.startCurrentPeriod.toIso8601String(),
      'end_current_period': instance.endCurrentPeriod.toIso8601String(),
      'start_previous_period': instance.startPreviousPeriod.toIso8601String(),
      'end_previous_period': instance.endPreviousPeriod.toIso8601String(),
    };
