import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_reporting/api/response_models/user_response_model.dart';

part 'user_sign_in_response_model.g.dart';

@JsonSerializable()
class UserSignInResponseModel {
  @JsonKey(name: 'user')
  final UserResponseModel user;

  @JsonKey(name: 'token')
  final String token;

  UserSignInResponseModel({
    required this.token,
    required this.user,
  });

  factory UserSignInResponseModel.fromJson(Map<String, dynamic> json) => _$UserSignInResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserSignInResponseModelToJson(this);
}
