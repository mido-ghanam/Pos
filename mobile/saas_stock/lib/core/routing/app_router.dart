import 'package:flutter/material.dart';
import 'package:saas_stock/core/widgets/splash_screen.dart';
import 'package:saas_stock/features/auth_otp/ui/screens/otp_screen.dart';
import 'package:saas_stock/features/backup/ui/screens/backup.dart';
import 'package:saas_stock/features/customers/ui/screens/screen_customers_screen.dart';
import 'package:saas_stock/features/products/ui/screens/add_edit_product_screen.dart';
import 'package:saas_stock/features/products/ui/screens/screen_products_screen.dart';
import 'package:saas_stock/features/reports/ui/screens/reports.dart';
import 'package:saas_stock/features/returns/ui/screens/returns.dart';
import 'package:saas_stock/features/sales/ui/screens/sales.dart';
import 'package:saas_stock/features/sales/ui/screens/sales_invoices_screen.dart';
import 'package:saas_stock/features/signup/ui/register_page.dart';
import 'package:saas_stock/features/suppliers/ui/screens/add_edit_supplier_screen.dart';
import 'package:saas_stock/features/suppliers/ui/screens/suppliers_screen.dart';
import 'routers.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../../features/login/ui/screens/login_screen.dart';
import '../../features/dashboard/ui/screens/dashboard_screen.dart';
import '../../features/barcode/ui/screens/barcode_screen.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ===== Auth Routes =====
      case Routers.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case Routers.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routers.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case Routers.otp:
        final args = settings.arguments as OtpArgs?;
        return MaterialPageRoute(
          builder: (_) => OtpScreen(args: args),
        );

      // ===== Main Navigation (BottomNav or Desktop Layout) =====
      case Routers.home:
        return MaterialPageRoute(builder: (_) => const AppBottomNavBar());

      // ===== Direct Routes (Optional) =====
      case Routers.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case Routers.products:
        return MaterialPageRoute(builder: (_) => const ProductsScreen());
      case Routers.addProduct:
        return MaterialPageRoute(builder: (_) => const AddEditProductScreen());

      case Routers.sales:
        return MaterialPageRoute(builder: (_) => const SalesScreen());
      case Routers.salesInvoices:
        return MaterialPageRoute(builder: (_) => const SalesInvoicesScreen());

      case Routers.suppliers:
        return MaterialPageRoute(builder: (_) => const SuppliersScreen());
      case Routers.addSupplier:
        return MaterialPageRoute(builder: (_) => const AddEditSupplierScreen());
      case Routers.purchases:
        return MaterialPageRoute(builder: (_) => Container());

      case Routers.returns:
        return MaterialPageRoute(builder: (_) => ReturnsHomeScreen());

      case Routers.barcode:
        return MaterialPageRoute(builder: (_) => const BarcodeScreen());

      case Routers.reports:
        return MaterialPageRoute(builder: (_) => const ReportsScreen());

      case Routers.customers:
        return MaterialPageRoute(builder: (_) => const CustomersScreen());

      case Routers.backup:
        return MaterialPageRoute(builder: (_) => const BackupScreen());

      // ===== Default / Not Found =====
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('خطأ')),
            body: const Center(
              child: Text('الصفحة غير موجودة', style: TextStyle(fontSize: 18)),
            ),
          ),
        );
    }
  }
}
