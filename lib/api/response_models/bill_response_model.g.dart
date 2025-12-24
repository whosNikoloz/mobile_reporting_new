// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillResponseModel _$BillResponseModelFromJson(Map<String, dynamic> json) =>
    BillResponseModel(
      amount: (json['amount'] as num).toDouble(),
      docNum: json['doc_num'] as String,
      id: (json['id'] as num).toInt(),
      orderType: json['order_type'] as String,
      roomName: json['room_name'] as String,
      storeName: json['store_name'] as String,
      tdate: DateTime.parse(json['tdate'] as String),
      userName: json['user_name'] as String,
    );

Map<String, dynamic> _$BillResponseModelToJson(BillResponseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tdate': instance.tdate.toIso8601String(),
      'doc_num': instance.docNum,
      'amount': instance.amount,
      'user_name': instance.userName,
      'store_name': instance.storeName,
      'room_name': instance.roomName,
      'order_type': instance.orderType,
    };
