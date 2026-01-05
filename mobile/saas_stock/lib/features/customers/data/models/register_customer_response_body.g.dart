// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_customer_response_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterCustomerResponseBody _$RegisterCustomerResponseBodyFromJson(
        Map<String, dynamic> json) =>
    RegisterCustomerResponseBody(
      status: json['status'] as bool?,
      message: json['message'] as String?,
      phone: json['phone'] as String?,
      nextStep: json['next_step'] as String?,
    );

Map<String, dynamic> _$RegisterCustomerResponseBodyToJson(
        RegisterCustomerResponseBody instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'phone': instance.phone,
      'next_step': instance.nextStep,
    };
