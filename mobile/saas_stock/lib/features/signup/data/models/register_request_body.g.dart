// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterRequestBody _$RegisterRequestBodyFromJson(Map<String, dynamic> json) =>
    RegisterRequestBody(
      username: json['username'] as String,
      password: json['password'] as String,
      phone: json['phone'] as String,
      first_name: json['first_name'] as String,
      last_name: json['last_name'] as String,
    );

Map<String, dynamic> _$RegisterRequestBodyToJson(
        RegisterRequestBody instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
      'phone': instance.phone,
      'first_name': instance.first_name,
      'last_name': instance.last_name,
    };
