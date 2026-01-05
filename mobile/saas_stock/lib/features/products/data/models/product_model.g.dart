// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      category: json['category'],
      barcode: (json['barcode'] as num?)?.toInt(),
      quantity: (json['quantity'] as num?)?.toDouble(),
      buyPrice: (json['buy_price'] as num?)?.toDouble(),
      sellPrice: (json['sell_price'] as num?)?.toDouble(),
      minQuantity: (json['min_quantity'] as num?)?.toDouble(),
      active: json['active'] as bool?,
      monitor: json['monitor'] as bool?,
      discription: json['discription'] as String?,
    );

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'barcode': instance.barcode,
      'quantity': instance.quantity,
      'buy_price': instance.buyPrice,
      'sell_price': instance.sellPrice,
      'min_quantity': instance.minQuantity,
      'active': instance.active,
      'monitor': instance.monitor,
      'discription': instance.discription,
    };

ProductsResponseBody _$ProductsResponseBodyFromJson(
        Map<String, dynamic> json) =>
    ProductsResponseBody(
      status: json['status'] as bool?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProductsResponseBodyToJson(
        ProductsResponseBody instance) =>
    <String, dynamic>{
      'status': instance.status,
      'data': instance.data,
    };
