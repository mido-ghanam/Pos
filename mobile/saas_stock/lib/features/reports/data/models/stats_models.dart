import 'package:saas_stock/features/sales/data/models/sale_models.dart';
import 'package:saas_stock/features/purchases/data/models/purchase_invoice_model.dart';

class SalesStatsResponse {
  final String period;
  final DateTime from;
  final DateTime to;
  final int totalInvoices;
  final double totalSales;
  final List<SaleResponse> invoices;

  SalesStatsResponse({
    required this.period,
    required this.from,
    required this.to,
    required this.totalInvoices,
    required this.totalSales,
    required this.invoices,
  });

  factory SalesStatsResponse.fromJson(Map<String, dynamic> json) {
    return SalesStatsResponse(
      period: json['period'] ?? '',
      from: DateTime.parse(json['from']),
      to: DateTime.parse(json['to']),
      totalInvoices: json['total_invoices'] ?? 0,
      totalSales: (json['total_sales'] ?? 0).toDouble(),
      invoices: (json['invoices'] as List)
          .map((e) => SaleResponse.fromJson(e))
          .toList(),
    );
  }
}

class PurchasesStatsResponse {
  final String period;
  final DateTime from;
  final DateTime to;
  final int totalInvoices;
  final double totalPurchases;
  final List<PurchaseInvoiceModel> invoices;

  PurchasesStatsResponse({
    required this.period,
    required this.from,
    required this.to,
    required this.totalInvoices,
    required this.totalPurchases,
    required this.invoices,
  });

  factory PurchasesStatsResponse.fromJson(Map<String, dynamic> json) {
    return PurchasesStatsResponse(
      period: json['period'] ?? '',
      from: DateTime.parse(json['from']),
      to: DateTime.parse(json['to']),
      totalInvoices: json['total_invoices'] ?? 0,
      totalPurchases: (json['total_purchases'] ?? 0).toDouble(),
      invoices: (json['invoices'] as List)
          .map((e) => PurchaseInvoiceModel.fromJson(e))
          .toList(),
    );
  }
}
