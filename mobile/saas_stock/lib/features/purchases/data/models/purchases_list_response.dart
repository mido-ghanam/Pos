import 'purchase_invoice_model.dart';

class PurchasesListResponse {
  final int totalInvoices;
  final double totalPurchases;
  final List<PurchaseInvoiceModel> invoices;

  PurchasesListResponse({
    required this.totalInvoices,
    required this.totalPurchases,
    required this.invoices,
  });

  factory PurchasesListResponse.fromJson(Map<String, dynamic> json) {
    return PurchasesListResponse(
      totalInvoices: json['total_invoices'],
      totalPurchases: (json['total_purchases'] as num).toDouble(),
      invoices: (json['invoices'] as List)
          .map((e) => PurchaseInvoiceModel.fromJson(e))
          .toList(),
    );
  }
}
