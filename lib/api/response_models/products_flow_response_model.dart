import 'package:json_annotation/json_annotation.dart';

part 'products_flow_response_model.g.dart';

@JsonSerializable()
class ProductsFlowResponseModel {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'price')
  final double price;

  @JsonKey(name: 'quantity')
  final double quantity;

  ProductsFlowResponseModel({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory ProductsFlowResponseModel.fromJson(Map<String, dynamic> json) => _$ProductsFlowResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductsFlowResponseModelToJson(this);
}
