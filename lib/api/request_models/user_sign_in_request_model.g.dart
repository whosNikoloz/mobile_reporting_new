// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_sign_in_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSignInRequestModel _$UserSignInRequestModelFromJson(
        Map<String, dynamic> json) =>
    UserSignInRequestModel(
      password: json['password'] as String,
      login: json['login'] as String,
    );

Map<String, dynamic> _$UserSignInRequestModelToJson(
        UserSignInRequestModel instance) =>
    <String, dynamic>{
      'login': instance.login,
      'password': instance.password,
    };
