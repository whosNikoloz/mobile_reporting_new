// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_entities_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentEntitiesRequestModel _$PaymentEntitiesRequestModelFromJson(
        Map<String, dynamic> json) =>
    PaymentEntitiesRequestModel(
      storeId: (json['store_id'] as num?)?.toInt() ?? 0,
      top: (json['top'] as num?)?.toInt() ?? 0,
      startPreviousPeriod:
          DateTime.parse(json['start_previous_period'] as String),
      endPreviousPeriod: DateTime.parse(json['end_previous_period'] as String),
      startCurrentPeriod:
          DateTime.parse(json['start_current_period'] as String),
      endCurrentPeriod: DateTime.parse(json['end_current_period'] as String),
    );

Map<String, dynamic> _$PaymentEntitiesRequestModelToJson(
        PaymentEntitiesRequestModel instance) =>
    <String, dynamic>{
      'store_id': instance.storeId,
      'top': instance.top,
      'start_previous_period': instance.startPreviousPeriod.toIso8601String(),
      'end_previous_period': instance.endPreviousPeriod.toIso8601String(),
      'start_current_period': instance.startCurrentPeriod.toIso8601String(),
      'end_current_period': instance.endCurrentPeriod.toIso8601String(),
    };
