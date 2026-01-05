// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_category_response_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddCategoryResponseBody _$AddCategoryResponseBodyFromJson(
        Map<String, dynamic> json) =>
    AddCategoryResponseBody(
      status: json['status'] as bool?,
      message: json['message'] as String?,
      categoryId: json['category_id'] as String?,
    );

Map<String, dynamic> _$AddCategoryResponseBodyToJson(
        AddCategoryResponseBody instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'category_id': instance.categoryId,
    };
