import 'package:json_annotation/json_annotation.dart';
part 'add_product_request_body.g.dart';

@JsonSerializable()
class AddProductRequestBody {
  final String name;
  final int barcode;
  final String category; // ✅ هيبقى UUID هنا
  
  @JsonKey(name: 'buy_price')
  final double buyPrice;
  
  final String? discription;
  
  @JsonKey(name: 'min_quantity')
  final double minQuantity;
  
  final double quantity;
  
  @JsonKey(name: 'sell_price')
  final double sellPrice;
  
  final bool active;
  final bool monitor;

  AddProductRequestBody({
    required this.name,
    required this.barcode,
    required this.category, // ✅ UUID
    required this.buyPrice,
    this.discription,
    required this.minQuantity,
    required this.quantity,
    required this.sellPrice,
    required this.active,
    required this.monitor,
  });

  Map<String, dynamic> toJson() => _$AddProductRequestBodyToJson(this);
}
