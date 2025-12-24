// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreResponseModel _$StoreResponseModelFromJson(Map<String, dynamic> json) =>
    StoreResponseModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$StoreResponseModelToJson(StoreResponseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
