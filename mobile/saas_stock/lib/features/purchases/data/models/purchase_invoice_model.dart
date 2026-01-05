class PurchaseInvoiceModel {
  final int id;
  final SupplierInfo supplier;
  final String total;
  final String paymentMethod;
  final DateTime createdAt;
  final List<PurchaseItemModel> items;

  PurchaseInvoiceModel({
    required this.id,
    required this.supplier,
    required this.total,
    required this.paymentMethod,
    required this.createdAt,
    required this.items,
  });

  factory PurchaseInvoiceModel.fromJson(Map<String, dynamic> json) {
    return PurchaseInvoiceModel(
      id: json['id'],
      supplier: SupplierInfo.fromJson(json['supplier']),
      total: json['total'].toString(),
      paymentMethod: json['payment_method'],
      createdAt: DateTime.parse(json['created_at']),
      items: (json['items'] as List)
          .map((e) => PurchaseItemModel.fromJson(e))
          .toList(),
    );
  }
}

class SupplierInfo {
  final String id;
  final String personName;
  final String companyName;
  final String phone;

  SupplierInfo({
    required this.id,
    required this.personName,
    required this.companyName,
    required this.phone,
  });

  factory SupplierInfo.fromJson(Map<String, dynamic> json) {
    return SupplierInfo(
      id: json['id'],
      personName: json['person_name'] ?? '',
      companyName: json['company_name'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  String get displayName =>
      companyName.isNotEmpty ? companyName : personName;
}

class PurchaseItemModel {
  final int id;
  final String product;
  final String productName;
  final int quantity;
  final String unitPrice;
  final String subtotal;

  PurchaseItemModel({
    required this.id,
    required this.product,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseItemModel(
      id: json['id'],
      product: json['product'],
      productName: json['product_name'],
      quantity: json['quantity'],
      unitPrice: json['unit_price'].toString(),
      subtotal: json['subtotal'].toString(),
    );
  }
}
