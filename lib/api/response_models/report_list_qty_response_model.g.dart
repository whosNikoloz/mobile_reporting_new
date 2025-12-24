// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_list_qty_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportListQtyResponseModel _$ReportListQtyResponseModelFromJson(
        Map<String, dynamic> json) =>
    ReportListQtyResponseModel(
      name: json['name'] as String,
      currentValue: (json['current_value'] as num).toDouble(),
      id: (json['id'] as num).toInt(),
      oldValue: (json['old_value'] as num).toDouble(),
      currentQuantity: (json['current_quantity'] as num).toDouble(),
      oldQuantity: (json['old_quantity'] as num).toDouble(),
    );

Map<String, dynamic> _$ReportListQtyResponseModelToJson(
        ReportListQtyResponseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'current_value': instance.currentValue,
      'old_value': instance.oldValue,
      'current_quantity': instance.currentQuantity,
      'old_quantity': instance.oldQuantity,
    };
