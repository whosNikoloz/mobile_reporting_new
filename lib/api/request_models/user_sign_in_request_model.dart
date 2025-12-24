import 'package:json_annotation/json_annotation.dart';

part 'user_sign_in_request_model.g.dart';

@JsonSerializable()
class UserSignInRequestModel {
  @JsonKey(name: 'login')
  final String login;

  @JsonKey(name: 'password')
  final String password;

  UserSignInRequestModel({
    required this.password,
    required this.login,
  });

  factory UserSignInRequestModel.fromJson(Map<String, dynamic> json) => _$UserSignInRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserSignInRequestModelToJson(this);
}
