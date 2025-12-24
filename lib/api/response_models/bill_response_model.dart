import 'package:json_annotation/json_annotation.dart';

part 'bill_response_model.g.dart';

@JsonSerializable()
class BillResponseModel {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'tdate')
  final DateTime tdate;

  @JsonKey(name: 'doc_num')
  final String docNum;

  @JsonKey(name: 'amount')
  final double amount;

  @JsonKey(name: 'user_name')
  final String userName;

  @JsonKey(name: 'store_name')
  final String storeName;

  @JsonKey(name: 'room_name')
  final String roomName;

  @JsonKey(name: 'order_type')
  final String orderType;

  BillResponseModel({
    required this.amount,
    required this.docNum,
    required this.id,
    required this.orderType,
    required this.roomName,
    required this.storeName,
    required this.tdate,
    required this.userName,
  });

  factory BillResponseModel.fromJson(Map<String, dynamic> json) => _$BillResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$BillResponseModelToJson(this);
}
