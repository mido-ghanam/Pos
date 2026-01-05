class CreatePurchaseRequest {
  final String supplierId;
  final String paymentMethod;
  final List<CreatePurchaseProduct> products;

  CreatePurchaseRequest({
    required this.supplierId,
    required this.paymentMethod,
    required this.products,
  });

  Map<String, dynamic> toJson() => {
        "supplier_id": supplierId,
        "payment_method": paymentMethod,
        "products": products.map((e) => e.toJson()).toList(),
      };
}

class CreatePurchaseProduct {
  final String productId;
  final int quantity;

  CreatePurchaseProduct({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        "product_id": productId,
        "quantity": quantity,
      };
}
