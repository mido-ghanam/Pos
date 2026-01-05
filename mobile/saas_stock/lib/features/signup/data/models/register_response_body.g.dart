// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_response_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterResponseBody _$RegisterResponseBodyFromJson(
        Map<String, dynamic> json) =>
    RegisterResponseBody(
      status: json['status'] as bool?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$RegisterResponseBodyToJson(
        RegisterResponseBody instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
    };
