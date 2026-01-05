// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_product_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddProductRequestBody _$AddProductRequestBodyFromJson(
        Map<String, dynamic> json) =>
    AddProductRequestBody(
      name: json['name'] as String,
      barcode: (json['barcode'] as num).toInt(),
      category: json['category'] as String,
      buyPrice: (json['buy_price'] as num).toDouble(),
      discription: json['discription'] as String?,
      minQuantity: (json['min_quantity'] as num).toDouble(),
      quantity: (json['quantity'] as num).toDouble(),
      sellPrice: (json['sell_price'] as num).toDouble(),
      active: json['active'] as bool,
      monitor: json['monitor'] as bool,
    );

Map<String, dynamic> _$AddProductRequestBodyToJson(
        AddProductRequestBody instance) =>
    <String, dynamic>{
      'name': instance.name,
      'barcode': instance.barcode,
      'category': instance.category,
      'buy_price': instance.buyPrice,
      'discription': instance.discription,
      'min_quantity': instance.minQuantity,
      'quantity': instance.quantity,
      'sell_price': instance.sellPrice,
      'active': instance.active,
      'monitor': instance.monitor,
    };
