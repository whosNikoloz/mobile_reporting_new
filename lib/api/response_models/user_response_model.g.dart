// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserResponseModel _$UserResponseModelFromJson(Map<String, dynamic> json) =>
    UserResponseModel(
      database: json['database'] as String,
      companyName: json['company_name'] as String,
      lang: json['lang'] as String,
      type: json['type'] as String,
      userName: json['user_name'] as String,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$UserResponseModelToJson(UserResponseModel instance) =>
    <String, dynamic>{
      'database': instance.database,
      'company_name': instance.companyName,
      'user_name': instance.userName,
      'lang': instance.lang,
      'type': instance.type,
      'url': instance.url,
    };
