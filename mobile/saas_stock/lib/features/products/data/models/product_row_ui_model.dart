
class ProductRowUiModel {
  final String code;
  final String name;
  final String category;
  final String barcode;
  final int stockQty;
  final String unit;
  final double costPrice;
  final double salePrice;
  final bool isActive;

  ProductRowUiModel({
    required this.code,
    required this.name,
    required this.category,
    required this.barcode,
    required this.stockQty,
    required this.unit,
    required this.costPrice,
    required this.salePrice,
    required this.isActive,
  });
}
