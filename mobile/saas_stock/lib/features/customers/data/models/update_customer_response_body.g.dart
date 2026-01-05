// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_customer_response_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateCustomerResponseBody _$UpdateCustomerResponseBodyFromJson(
        Map<String, dynamic> json) =>
    UpdateCustomerResponseBody(
      status: json['status'] as bool?,
      data: json['data'] == null
          ? null
          : CustomerModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UpdateCustomerResponseBodyToJson(
        UpdateCustomerResponseBody instance) =>
    <String, dynamic>{
      'status': instance.status,
      'data': instance.data,
    };
