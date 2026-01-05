class SaleResponse {
  final int id;
  final CustomerInfo customer;
  final String total;
  final String paymentMethod;
  final DateTime createdAt;
  final List<SaleItem> items;

  SaleResponse({
    required this.id,
    required this.customer,
    required this.total,
    required this.paymentMethod,
    required this.createdAt,
    required this.items,
  });

  factory SaleResponse.fromJson(Map<String, dynamic> json) {
    return SaleResponse(
      id: json['id'],
      customer: CustomerInfo.fromJson(json['customer']),
      total: json['total'].toString(),
      paymentMethod: json['payment_method'],
      createdAt: DateTime.parse(json['created_at']),
      items: (json['items'] as List)
          .map((e) => SaleItem.fromJson(e))
          .toList(),
    );
  }
}

class SalesListResponse {
  final int totalInvoices;
  final double totalSales;
  final List<SaleResponse> invoices;

  SalesListResponse({
    required this.totalInvoices,
    required this.totalSales,
    required this.invoices,
  });

  factory SalesListResponse.fromJson(Map<String, dynamic> json) {
    return SalesListResponse(
      totalInvoices: json['total_invoices'] ?? 0,
      totalSales: (json['total_sales'] ?? 0).toDouble(),
      invoices: (json['invoices'] as List)
          .map((e) => SaleResponse.fromJson(e))
          .toList(),
    );
  }
}

class CustomerInfo {
  final String id;
  final String name;
  final String phone;
  final String address;

  CustomerInfo({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      id: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
    );
  }
}

class SaleItem {
  final int id;
  final String product;
  final String productName;
  final int quantity;
  final String unitPrice;
  final String subtotal;

  SaleItem({
    required this.id,
    required this.product,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      id: json['id'],
      product: json['product'],
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: json['unit_price'].toString(),
      subtotal: json['subtotal'].toString(),
    );
  }
}
