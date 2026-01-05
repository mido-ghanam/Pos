class PartnerInvoicesResponse {
  final int totalInvoices;
  final double totalValue;
  final List<InvoiceModel> invoices;

  PartnerInvoicesResponse({
    required this.totalInvoices,
    required this.totalValue,
    required this.invoices,
  });

  factory PartnerInvoicesResponse.fromJson(Map<String, dynamic> json) {
    return PartnerInvoicesResponse(
      totalInvoices: json["total_invoices"] ?? 0,
      totalValue: (json["total_sales"] ?? json["total_purchases"] ?? 0 as num).toDouble(),
      invoices: (json["invoices"] as List? ?? [])
          .map((e) => InvoiceModel.fromJson(e))
          .toList(),
    );
  }
}

class InvoiceModel {
  final int id;
  final String total;
  final String paymentMethod;
  final DateTime createdAt;
  final List<InvoiceItemModel> items;

  InvoiceModel({
    required this.id,
    required this.total,
    required this.paymentMethod,
    required this.createdAt,
    required this.items,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json["id"],
      total: json["total"].toString(),
      paymentMethod: json["payment_method"] ?? "",
      createdAt: DateTime.parse(json["created_at"]),
      items: (json["items"] as List? ?? [])
          .map((e) => InvoiceItemModel.fromJson(e))
          .toList(),
    );
  }
}

class InvoiceItemModel {
  final String productId;
  final String productName;
  final int quantity;
  final String unitPrice;
  final String subtotal;

  InvoiceItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      productId: json["product"].toString(),
      productName: json["product_name"].toString(),
      quantity: json["quantity"] ?? 0,
      unitPrice: json["unit_price"].toString(),
      subtotal: json["subtotal"].toString(),
    );
  }
}
