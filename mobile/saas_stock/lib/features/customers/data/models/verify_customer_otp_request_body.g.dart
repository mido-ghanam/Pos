// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_customer_otp_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyCustomerOtpRequestBody _$VerifyCustomerOtpRequestBodyFromJson(
        Map<String, dynamic> json) =>
    VerifyCustomerOtpRequestBody(
      phone: json['phone'] as String,
      otpCode: json['otp_code'] as String,
    );

Map<String, dynamic> _$VerifyCustomerOtpRequestBodyToJson(
        VerifyCustomerOtpRequestBody instance) =>
    <String, dynamic>{
      'phone': instance.phone,
      'otp_code': instance.otpCode,
    };
