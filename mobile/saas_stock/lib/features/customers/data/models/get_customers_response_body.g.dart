// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_customers_response_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetCustomersResponseBody _$GetCustomersResponseBodyFromJson(
        Map<String, dynamic> json) =>
    GetCustomersResponseBody(
      status: json['status'] as bool?,
      count: (json['count'] as num?)?.toInt(),
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetCustomersResponseBodyToJson(
        GetCustomersResponseBody instance) =>
    <String, dynamic>{
      'status': instance.status,
      'count': instance.count,
      'data': instance.data,
    };
