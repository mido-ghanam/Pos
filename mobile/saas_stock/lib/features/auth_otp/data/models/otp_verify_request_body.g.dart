// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_verify_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtpVerifyRequestBody _$OtpVerifyRequestBodyFromJson(
        Map<String, dynamic> json) =>
    OtpVerifyRequestBody(
      username: json['username'] as String,
      otp: json['otp'] as String,
    );

Map<String, dynamic> _$OtpVerifyRequestBodyToJson(
        OtpVerifyRequestBody instance) =>
    <String, dynamic>{
      'username': instance.username,
      'otp': instance.otp,
    };
