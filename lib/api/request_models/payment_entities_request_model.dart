import 'package:json_annotation/json_annotation.dart';

part 'payment_entities_request_model.g.dart';

@JsonSerializable()
class PaymentEntitiesRequestModel {
  @JsonKey(name: 'store_id')
  final int storeId;

  @JsonKey(name: 'top')
  final int top;

  @JsonKey(name: 'start_previous_period')
  final DateTime startPreviousPeriod;

  @JsonKey(name: 'end_previous_period')
  final DateTime endPreviousPeriod;

  @JsonKey(name: 'start_current_period')
  final DateTime startCurrentPeriod;

  @JsonKey(name: 'end_current_period')
  final DateTime endCurrentPeriod;

  PaymentEntitiesRequestModel({
    this.storeId = 0,
    this.top = 0,
    required this.startPreviousPeriod,
    required this.endPreviousPeriod,
    required this.startCurrentPeriod,
    required this.endCurrentPeriod,
  });

  factory PaymentEntitiesRequestModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentEntitiesRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentEntitiesRequestModelToJson(this);
}
