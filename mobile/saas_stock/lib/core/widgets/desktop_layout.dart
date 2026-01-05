import 'package:flutter/material.dart';
import 'package:saas_stock/features/customers/ui/screens/screen_customers_screen.dart';
import 'package:saas_stock/features/products/ui/screens/screen_products_screen.dart';
import 'package:saas_stock/features/purchases/ui/screens/purshase.dart';
import 'package:saas_stock/features/reports/ui/screens/reports.dart';
import 'package:saas_stock/features/returns/ui/screens/returns.dart';
import 'package:saas_stock/features/sales/ui/screens/sales.dart';
import 'package:saas_stock/features/suppliers/ui/screens/suppliers_screen.dart';
import '../../features/dashboard/ui/screens/dashboard_screen.dart';

class DesktopLayout extends StatefulWidget {
  const DesktopLayout({super.key});

  @override
  State<DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<DesktopLayout> {
  int _selectedIndex = 0;
  bool _isExpanded = true;

  final List<_MenuItem> _menuItems = [
    _MenuItem(
      icon: Icons.dashboard,
      title: 'لوحة التحكم',
      screen: const DashboardScreen(),
    ),
    _MenuItem(
      icon: Icons.inventory_2,
      title: 'المنتجات',
      screen: const ProductsScreen(),
    ),
    _MenuItem(
      icon: Icons.people,
      title: 'العملاء',
      screen: const CustomersScreen(),
    ),
    _MenuItem(
      icon: Icons.shopping_cart,
      title: 'المبيعات',
      screen: const SalesScreen(),
    ),
    _MenuItem(
      icon: Icons.shopping_bag,
      title: 'الموردين',
      screen: const SuppliersScreen(),
    ),
    _MenuItem(
      icon: Icons.shopping_bag,
      title: 'المشتريات',
      screen: const PurchasesScreen(),
    ),
    _MenuItem(
      icon: Icons.keyboard_return,
      title: 'المرتجعات',
      screen: ReturnsHomeScreen(),
    ),
    _MenuItem(
      icon: Icons.bar_chart,
      title: 'التقارير',
      screen: const ReportsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ===== Sidebar =====
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isExpanded ? 260 : 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Logo Section
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFF7C3AED),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.store,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      if (_isExpanded) ...[
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'نظام المخازن',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const Divider(color: Colors.white24, height: 1),

                // Menu Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final item = _menuItems[index];
                      final isSelected = _selectedIndex == index;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF7C3AED)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    item.icon,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  if (_isExpanded) ...[
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const Divider(color: Colors.white24, height: 1),

                // Toggle Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isExpanded
                                ? Icons.arrow_back_ios
                                : Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===== Main Content =====
          Expanded(
            child: _menuItems[_selectedIndex].screen,
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final Widget screen;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.screen,
  });
}
