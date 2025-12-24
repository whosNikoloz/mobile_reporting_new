// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_details_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillDetailsResponseModel _$BillDetailsResponseModelFromJson(
        Map<String, dynamic> json) =>
    BillDetailsResponseModel(
      id: (json['id'] as num).toInt(),
      payments: (json['payments'] as List<dynamic>)
          .map((e) => PaymentResponseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      products: (json['products'] as List<dynamic>)
          .map((e) =>
              ProductsFlowResponseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BillDetailsResponseModelToJson(
        BillDetailsResponseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'products': instance.products,
      'payments': instance.payments,
    };
