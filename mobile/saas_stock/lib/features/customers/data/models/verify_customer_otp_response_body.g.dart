// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_customer_otp_response_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyCustomerOtpResponseBody _$VerifyCustomerOtpResponseBodyFromJson(
        Map<String, dynamic> json) =>
    VerifyCustomerOtpResponseBody(
      status: json['status'] as bool?,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : CustomerModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VerifyCustomerOtpResponseBodyToJson(
        VerifyCustomerOtpResponseBody instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'data': instance.data,
    };
