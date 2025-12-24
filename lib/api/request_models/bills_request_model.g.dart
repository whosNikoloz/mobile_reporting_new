// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bills_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillsRequestModel _$BillsRequestModelFromJson(Map<String, dynamic> json) =>
    BillsRequestModel(
      endDate: DateTime.parse(json['endDate'] as String),
      paramId: (json['param_id'] as num).toInt(),
      startDate: DateTime.parse(json['start_date'] as String),
      billNum: json['bill_num'] as String?,
      maxAmount: (json['end_amount'] as num?)?.toDouble(),
      minAmount: (json['start_amount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$BillsRequestModelToJson(BillsRequestModel instance) =>
    <String, dynamic>{
      'param_id': instance.paramId,
      'start_date': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'start_amount': instance.minAmount,
      'end_amount': instance.maxAmount,
      'bill_num': instance.billNum,
    };
