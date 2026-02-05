import 'package:json_annotation/json_annotation.dart';

part 'payment_entities_response_model.g.dart';

@JsonSerializable()
class PaymentEntitiesResponseModel {
  @JsonKey(name: 'entity_name')
  final String entityName;

  @JsonKey(name: 'previous_qnt')
  final int previousQnt;

  @JsonKey(name: 'previous_amount')
  final double previousAmount;

  @JsonKey(name: 'current_qnt')
  final int currentQnt;

  @JsonKey(name: 'current_amount')
  final double currentAmount;

  PaymentEntitiesResponseModel({
    required this.entityName,
    required this.previousQnt,
    required this.previousAmount,
    required this.currentQnt,
    required this.currentAmount,
  });

  factory PaymentEntitiesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentEntitiesResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentEntitiesResponseModelToJson(this);
}
