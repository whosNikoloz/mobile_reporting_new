// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_sign_in_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSignInResponseModel _$UserSignInResponseModelFromJson(
        Map<String, dynamic> json) =>
    UserSignInResponseModel(
      token: json['token'] as String,
      user: UserResponseModel.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserSignInResponseModelToJson(
        UserSignInResponseModel instance) =>
    <String, dynamic>{
      'user': instance.user,
      'token': instance.token,
    };
