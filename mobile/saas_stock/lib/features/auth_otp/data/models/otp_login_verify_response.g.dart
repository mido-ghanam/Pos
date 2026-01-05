// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_login_verify_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtpLoginVerifyResponse _$OtpLoginVerifyResponseFromJson(
        Map<String, dynamic> json) =>
    OtpLoginVerifyResponse(
      status: json['status'] as bool?,
      data: json['data'] == null
          ? null
          : UserData.fromJson(json['data'] as Map<String, dynamic>),
      tokens: json['tokens'] == null
          ? null
          : Tokens.fromJson(json['tokens'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OtpLoginVerifyResponseToJson(
        OtpLoginVerifyResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'data': instance.data,
      'tokens': instance.tokens,
    };
