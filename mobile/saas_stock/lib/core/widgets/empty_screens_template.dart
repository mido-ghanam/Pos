// ===== استخدم هذا Template لإنشاء الصفحات الفارغة =====

// features/products/ui/screens/products_screen.dart
import 'package:flutter/material.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المنتجات'),
      ),
      body: const Center(
        child: Text(
          'شاشة المنتجات - قريباً',
          style: TextStyle(fontSize: 20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF7C3AED),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ===== كرر نفس الشكل لباقي الصفحات =====
// - SalesScreen
// - PurchasesScreen
// - ReturnsScreen
// - BarcodeScreen
// - ReportsScreen
// - CustomersScreen
// - InventoryScreen
// - CashRegisterScreen
// - ExpensesScreen
// - UsersScreen
// - SettingsScreen
// - BackupScreen
