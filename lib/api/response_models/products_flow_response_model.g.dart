// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products_flow_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductsFlowResponseModel _$ProductsFlowResponseModelFromJson(
        Map<String, dynamic> json) =>
    ProductsFlowResponseModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toDouble(),
    );

Map<String, dynamic> _$ProductsFlowResponseModelToJson(
        ProductsFlowResponseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'quantity': instance.quantity,
    };
