// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_product_sales_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopProductSalesResponseModel _$TopProductSalesResponseModelFromJson(
        Map<String, dynamic> json) =>
    TopProductSalesResponseModel(
      productName: json['product_name'] as String? ?? "",
      previousQnt: (json['previous_qnt'] as num?)?.toInt() ?? 0,
      previousSales: (json['previous_sales'] as num?)?.toDouble() ?? 0.0,
      currentQnt: (json['current_qnt'] as num?)?.toInt() ?? 0,
      currentSales: (json['current_sales'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$TopProductSalesResponseModelToJson(
        TopProductSalesResponseModel instance) =>
    <String, dynamic>{
      'product_name': instance.productName,
      'previous_qnt': instance.previousQnt,
      'previous_sales': instance.previousSales,
      'current_qnt': instance.currentQnt,
      'current_sales': instance.currentSales,
    };
