class CreateRefundRequest {
  final String returnType; // "purchase" | "sales"
  final String partyId;    // supplierId or customerId
  final List<CreateRefundProduct> products;

  CreateRefundRequest({
    required this.returnType,
    required this.partyId,
    required this.products,
  });

  Map<String, dynamic> toJson() => {
        "return_type": returnType,
        "party_id": partyId,
        "products": products.map((e) => e.toJson()).toList(),
      };
}

class CreateRefundProduct {
  final String productId;
  final int quantity;

  CreateRefundProduct({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        "product_id": productId,
        "quantity": quantity,
      };
}
