// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerModel _$CustomerModelFromJson(Map<String, dynamic> json) =>
    CustomerModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      blocked: json['blocked'] as bool?,
      vip: json['vip'] as bool?,
      notes: json['notes'] as String?,
      isVerified: json['is_verified'] as bool?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$CustomerModelToJson(CustomerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'address': instance.address,
      'blocked': instance.blocked,
      'vip': instance.vip,
      'notes': instance.notes,
      'is_verified': instance.isVerified,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
