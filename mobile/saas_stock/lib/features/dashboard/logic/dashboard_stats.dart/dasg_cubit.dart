import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/di/dependency_injection.dart';
import 'package:saas_stock/features/customers/logic/cubit.dart';
import 'package:saas_stock/features/dashboard/data/models/dashboard_stats.dart';
import 'package:saas_stock/features/dashboard/logic/dashboard_stats.dart/dash_stats.dart';
import 'package:saas_stock/features/products/logic/product/products_cubit.dart';
import 'package:saas_stock/features/purchases/logic/cubit.dart';
import 'package:saas_stock/features/purchases/logic/states.dart';
import 'package:saas_stock/features/returns/logic/cubit.dart';
import 'package:saas_stock/features/sales/logic/cubit.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(DashboardInitial());

  final SalesCubit salesCubit = getIt<SalesCubit>();
  final ReturnsCubit returnsCubit = getIt<ReturnsCubit>();
  final ProductsCubit productsCubit = getIt<ProductsCubit>();
  final CustomersCubit customersCubit = getIt<CustomersCubit>();
  final PurchasesCubit purchasesCubit = getIt<PurchasesCubit>();

  Future<void> loadDashboard() async {
    emit(DashboardLoading());

    try {
      // ✅ Load all data in parallel
      await Future.wait([
        salesCubit.loadSales(),
        returnsCubit.loadRefunds(),
        productsCubit.getAllProducts(),
        customersCubit.fetchCustomers(),
        purchasesCubit.fetchPurchases(),
      ]);

      // ✅ build stats
      final stats = _buildStats();

      emit(DashboardLoaded(stats));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  DashboardStats _buildStats() {
    final salesList = salesCubit.salesList;
    final refunds = returnsCubit.refunds;
    final products = productsCubit.products;
    final customers = customersCubit.customers;

    final purchasesState = purchasesCubit.state;

    // ✅ today helper (حل timezone + format)
    final now = DateTime.now();

    bool isSameDay(DateTime a, DateTime b) {
      final aa = a.toLocal();
      final bb = b.toLocal();
      return aa.year == bb.year && aa.month == bb.month && aa.day == bb.day;
    }

    // =================== Sales Today ===================
    double todaySalesAmount = 0;
    int todaySalesInvoices = 0;

    if (salesList != null) {
      for (final inv in salesList.invoices) {
        if (isSameDay(inv.createdAt, now)) {
          todaySalesInvoices++;
          todaySalesAmount += double.tryParse(inv.total) ?? 0;
        }
      }
    }

    // =================== Returns Today ===================
    int returnsToday = 0;

    if (refunds != null) {
      for (final r in refunds.invoices) {
        if (isSameDay(r.createdAt, now)) {
          returnsToday++;
        }
      }
    }

    // =================== Purchases Today ===================
    int todayPurchaseInvoices = 0;

    if (purchasesState is PurchasesLoaded) {
      for (final p in purchasesState.data.invoices) {
        if (isSameDay(p.createdAt, now)) {
          todayPurchaseInvoices++;
        }
      }
    }

    // =================== Stock Stats ===================
    final totalProducts = products.length;
    final lowStockProducts = productsCubit.lowStockProducts;

    // =================== Customers Stats ===================
    final totalCustomers = customers.length;

    int newCustomersToday = 0;

    for (final c in customers) {
      // ⚠️ لازم يكون عندك createdAt في customer model (string)
      final createdAtString = c.createdAt;

      if (createdAtString != null && createdAtString.isNotEmpty) {
        final parsedDate = DateTime.tryParse(createdAtString);
        if (parsedDate != null && isSameDay(parsedDate, now)) {
          newCustomersToday++;
        }
      }
    }

    return DashboardStats(
      todaySales: todaySalesAmount,
      todaySalesInvoices: todaySalesInvoices,
      todayPurchaseInvoices: todayPurchaseInvoices,
      totalInvoicesToday: todaySalesInvoices + todayPurchaseInvoices,
      totalProducts: totalProducts,
      lowStockProducts: lowStockProducts,
      totalCustomers: totalCustomers,
      newCustomersToday: newCustomersToday,
      returnsToday: returnsToday,
    );
  }
}
