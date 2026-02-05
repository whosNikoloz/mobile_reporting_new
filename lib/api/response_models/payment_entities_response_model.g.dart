// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_entities_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentEntitiesResponseModel _$PaymentEntitiesResponseModelFromJson(
        Map<String, dynamic> json) =>
    PaymentEntitiesResponseModel(
      entityName: json['entity_name'] as String,
      previousQnt: (json['previous_qnt'] as num).toInt(),
      previousAmount: (json['previous_amount'] as num).toDouble(),
      currentQnt: (json['current_qnt'] as num).toInt(),
      currentAmount: (json['current_amount'] as num).toDouble(),
    );

Map<String, dynamic> _$PaymentEntitiesResponseModelToJson(
        PaymentEntitiesResponseModel instance) =>
    <String, dynamic>{
      'entity_name': instance.entityName,
      'previous_qnt': instance.previousQnt,
      'previous_amount': instance.previousAmount,
      'current_qnt': instance.currentQnt,
      'current_amount': instance.currentAmount,
    };
