import 'package:flutter/material.dart';
import 'package:saas_stock/core/widgets/desktop_layout.dart';
import 'package:saas_stock/core/widgets/responsive_helper.dart';
import 'package:saas_stock/features/products/ui/screens/screen_products_screen.dart';
import 'package:saas_stock/features/purchases/ui/screens/purshase.dart';
import 'package:saas_stock/features/reports/ui/screens/reports.dart';
import 'package:saas_stock/features/sales/ui/screens/sales.dart';
import '../../features/dashboard/ui/screens/dashboard_screen.dart';


class AppBottomNavBar extends StatefulWidget {
  const AppBottomNavBar({super.key});

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ProductsScreen(),
    SalesScreen(),
    PurchasesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // ✅ إذا Desktop → استخدم Desktop Layout مع Sidebar
    if (ResponsiveHelper.isDesktop(context)) {
      return const DesktopLayout();
    }

    // ✅ إذا Mobile/Tablet → استخدم Bottom Navigation
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF7C3AED),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2),
              label: 'المنتجات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'المبيعات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.cabin_outlined),
              label: 'المشتريات',
            ),
          ],
        ),
      ),
    );
  }
}
