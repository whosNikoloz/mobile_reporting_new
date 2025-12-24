import 'package:json_annotation/json_annotation.dart';

part 'store_response_model.g.dart';

@JsonSerializable()
class StoreResponseModel {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'name')
  final String name;

  StoreResponseModel({
    required this.id,
    required this.name,
  });

  factory StoreResponseModel.fromJson(Map<String, dynamic> json) => _$StoreResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$StoreResponseModelToJson(this);
}
