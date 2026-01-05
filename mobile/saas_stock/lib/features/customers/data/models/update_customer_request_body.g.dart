// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_customer_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateCustomerRequestBody _$UpdateCustomerRequestBodyFromJson(
        Map<String, dynamic> json) =>
    UpdateCustomerRequestBody(
      name: json['name'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      blocked: json['blocked'] as bool,
      vip: json['vip'] as bool,
      notes: json['notes'] as String,
      isVerified: json['is_verified'] as bool,
    );

Map<String, dynamic> _$UpdateCustomerRequestBodyToJson(
        UpdateCustomerRequestBody instance) =>
    <String, dynamic>{
      'name': instance.name,
      'phone': instance.phone,
      'address': instance.address,
      'blocked': instance.blocked,
      'vip': instance.vip,
      'notes': instance.notes,
      'is_verified': instance.isVerified,
    };
