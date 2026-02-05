// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_sales_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategorySalesResponseModel _$CategorySalesResponseModelFromJson(
        Map<String, dynamic> json) =>
    CategorySalesResponseModel(
      categoryName: json['category_name'] as String,
      previousSales: (json['previous_sales'] as num).toDouble(),
      currentSales: (json['current_sales'] as num).toDouble(),
    );

Map<String, dynamic> _$CategorySalesResponseModelToJson(
        CategorySalesResponseModel instance) =>
    <String, dynamic>{
      'category_name': instance.categoryName,
      'previous_sales': instance.previousSales,
      'current_sales': instance.currentSales,
    };
