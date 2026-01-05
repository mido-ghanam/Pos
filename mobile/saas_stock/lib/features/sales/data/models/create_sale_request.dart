class CreateSaleRequest {
  final String customerId;
  final String paymentMethod; // Cash / Card / Transfer / Credit
  final List<CreateSaleProduct> products;

  CreateSaleRequest({
    required this.customerId,
    required this.paymentMethod,
    required this.products,
  });

  Map<String, dynamic> toJson() {
    return {
      "customer_id": customerId,
      "payment_method": paymentMethod,
      "products": products.map((e) => e.toJson()).toList(),
    };
  }
}

class CreateSaleProduct {
  final String productId;
  final int quantity;

  CreateSaleProduct({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      "product_id": productId,
      "quantity": quantity,
    };
  }
}
