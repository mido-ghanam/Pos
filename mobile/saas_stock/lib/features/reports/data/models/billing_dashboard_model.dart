class BillingDashboardModel {
  final double totalSales;
  final double totalPurchases;
  final double totalReturns;
  final double profit;

  BillingDashboardModel({
    required this.totalSales,
    required this.totalPurchases,
    required this.totalReturns,
    required this.profit,
  });

  factory BillingDashboardModel.fromJson(Map<String, dynamic> json) {
    return BillingDashboardModel(
      totalSales: (json["total_sales"] as num? ?? 0).toDouble(),
      totalPurchases: (json["total_purchases"] as num? ?? 0).toDouble(),
      totalReturns: (json["total_returns"] as num? ?? 0).toDouble(),
      profit: (json["profit"] as num? ?? 0).toDouble(),
    );
  }
}
