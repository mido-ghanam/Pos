class DashboardStats {
  final double todaySales;
  final int todaySalesInvoices;
  final int todayPurchaseInvoices;
  final int totalInvoicesToday;

  final int totalProducts;
  final int lowStockProducts;

  final int totalCustomers;
  final int newCustomersToday;

  final int returnsToday;

  DashboardStats({
    required this.todaySales,
    required this.todaySalesInvoices,
    required this.todayPurchaseInvoices,
    required this.totalInvoicesToday,
    required this.totalProducts,
    required this.lowStockProducts,
    required this.totalCustomers,
    required this.newCustomersToday,
    required this.returnsToday,
  });

  factory DashboardStats.empty() {
    return DashboardStats(
      todaySales: 0,
      todaySalesInvoices: 0,
      todayPurchaseInvoices: 0,
      totalInvoicesToday: 0,
      totalProducts: 0,
      lowStockProducts: 0,
      totalCustomers: 0,
      newCustomersToday: 0,
      returnsToday: 0,
    );
  }
}
