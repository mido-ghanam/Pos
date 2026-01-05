// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_customer_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterCustomerRequestBody _$RegisterCustomerRequestBodyFromJson(
        Map<String, dynamic> json) =>
    RegisterCustomerRequestBody(
      name: json['name'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      notes: json['notes'] as String,
    );

Map<String, dynamic> _$RegisterCustomerRequestBodyToJson(
        RegisterCustomerRequestBody instance) =>
    <String, dynamic>{
      'name': instance.name,
      'phone': instance.phone,
      'address': instance.address,
      'notes': instance.notes,
    };
