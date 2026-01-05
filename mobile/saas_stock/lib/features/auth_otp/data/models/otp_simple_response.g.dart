// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_simple_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtpSimpleResponse _$OtpSimpleResponseFromJson(Map<String, dynamic> json) =>
    OtpSimpleResponse(
      status: json['status'] as bool?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$OtpSimpleResponseToJson(OtpSimpleResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
    };
