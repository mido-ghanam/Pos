// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_product_response_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddProductResponseBody _$AddProductResponseBodyFromJson(
        Map<String, dynamic> json) =>
    AddProductResponseBody(
      status: json['status'] as bool?,
      message: json['message'] as String?,
      productId: json['product_id'] as String?,
    );

Map<String, dynamic> _$AddProductResponseBodyToJson(
        AddProductResponseBody instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'product_id': instance.productId,
    };
