import 'package:json_annotation/json_annotation.dart';

part 'user_response_model.g.dart';

@JsonSerializable()
class UserResponseModel {
  @JsonKey(name: 'database')
  final String database;

  @JsonKey(name: 'company_name')
  final String companyName;

  @JsonKey(name: 'user_name')
  final String userName;

  @JsonKey(name: 'lang')
  final String lang;

  @JsonKey(name: 'type')
  final String type;

  @JsonKey(name: 'url')
  final String? url;

  UserResponseModel({
    required this.database,
    required this.companyName,
    required this.lang,
    required this.type,
    required this.userName,
    required this.url,
  });

  factory UserResponseModel.fromJson(Map<String, dynamic> json) => _$UserResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserResponseModelToJson(this);
}
