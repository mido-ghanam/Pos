import 'package:intl/intl.dart';

class RefundInvoiceModel {
  final int id;
  final String partnerType; // "sale" | "purchase"
  final Map<String, dynamic>? customer;
  final Map<String, dynamic>? supplier;
  final String total;
  final DateTime createdAt;
  final List<RefundItemModel> items;

  RefundInvoiceModel({
    required this.id,
    required this.partnerType,
    required this.customer,
    required this.supplier,
    required this.total,
    required this.createdAt,
    required this.items,
  });

  factory RefundInvoiceModel.fromJson(Map<String, dynamic> json) {
    return RefundInvoiceModel(
      id: json["id"],
      partnerType: json["partner_type"] ?? "",
      customer: json["customer"] == null
          ? null
          : Map<String, dynamic>.from(json["customer"]),
      supplier: json["supplier"] == null
          ? null
          : Map<String, dynamic>.from(json["supplier"]),
      total: json["total"].toString(),
      createdAt: DateTime.parse(json["created_at"]),
      items: (json["items"] as List? ?? [])
          .map((e) => RefundItemModel.fromJson(e))
          .toList(),
    );
  }

  /// ✅ اسم العميل/المورد
  String get partyName {
    if (partnerType == "sale") {
      return (customer?["name"] ?? "-").toString();
    } else {
      return (supplier?["company_name"] ??
              supplier?["person_name"] ??
              "-")
          .toString();
    }
  }

  /// ✅ id للطرف
  String get partyId {
    if (partnerType == "sale") {
      return (customer?["id"] ?? "").toString();
    } else {
      return (supplier?["id"] ?? "").toString();
    }
  }

  bool get isSale => partnerType == "sale";
  bool get isPurchase => partnerType == "purchase";

  String get createdAtFormatted =>
      DateFormat('dd/MM/yyyy - hh:mm a', 'ar').format(createdAt);
}

class RefundItemModel {
  final int id;
  final String product;
  final String productName;
  final int quantity;
  final String unitPrice;
  final String subtotal;

  RefundItemModel({
    required this.id,
    required this.product,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory RefundItemModel.fromJson(Map<String, dynamic> json) {
    return RefundItemModel(
      id: json["id"],
      product: json["product"].toString(),
      productName: json["product_name"].toString(),
      quantity: json["quantity"] ?? 0,
      unitPrice: json["unit_price"].toString(),
      subtotal: json["subtotal"].toString(),
    );
  }
}

class RefundsListResponse {
  final int totalInvoices;
  final double totalReturns;
  final List<RefundInvoiceModel> invoices;

  RefundsListResponse({
    required this.totalInvoices,
    required this.totalReturns,
    required this.invoices,
  });

  factory RefundsListResponse.fromJson(Map<String, dynamic> json) {
    return RefundsListResponse(
      totalInvoices: json["total_invoices"] ?? 0,
      totalReturns: (json["total_returns"] as num? ?? 0).toDouble(),
      invoices: (json["invoices"] as List? ?? [])
          .map((e) => RefundInvoiceModel.fromJson(e))
          .toList(),
    );
  }
}
