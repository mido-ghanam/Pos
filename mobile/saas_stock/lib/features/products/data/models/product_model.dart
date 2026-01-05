import 'package:json_annotation/json_annotation.dart';
part 'product_model.g.dart';

@JsonSerializable()
class ProductModel {
  final String? id;
  final String? name;
  final dynamic category; // ✅ ممكن String أو Object
  final int? barcode;
  final double? quantity;
  
  @JsonKey(name: 'buy_price')
  final double? buyPrice;
  
  @JsonKey(name: 'sell_price')
  final double? sellPrice;
  
  @JsonKey(name: 'min_quantity')
  final double? minQuantity;
  
  final bool? active;
  final bool? monitor;
  final String? discription; // ✅ في details فقط

  ProductModel({
    this.id,
    this.name,
    this.category,
    this.barcode,
    this.quantity,
    this.buyPrice,
    this.sellPrice,
    this.minQuantity,
    this.active,
    this.monitor,
    this.discription,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  // ✅ Helper للحصول على اسم الفئة
  String get categoryName {
    if (category is String) return category as String;
    if (category is Map && category['name'] != null) {
      return category['name'] as String;
    }
    return '';
  }

  // ✅ Helper للحصول على category_id
  String? get categoryId {
    if (category is Map && category['id'] != null) {
      return category['id'] as String;
    }
    return null;
  }
}

@JsonSerializable()
class ProductsResponseBody {
  final bool? status;
  final List<ProductModel>? data;

  ProductsResponseBody({
    this.status,
    this.data,
  });

  factory ProductsResponseBody.fromJson(Map<String, dynamic> json) =>
      _$ProductsResponseBodyFromJson(json);
}
