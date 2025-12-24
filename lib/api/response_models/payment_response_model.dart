import 'package:json_annotation/json_annotation.dart';

part 'payment_response_model.g.dart';

@JsonSerializable()
class PaymentResponseModel {
  @JsonKey(name: 'amount')
  final double amount;

  @JsonKey(name: 'is_cash')
  final bool isCash;

  PaymentResponseModel({
    required this.amount,
    required this.isCash,
  });

  factory PaymentResponseModel.fromJson(Map<String, dynamic> json) => _$PaymentResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentResponseModelToJson(this);
}
