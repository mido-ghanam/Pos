import 'package:flutter/material.dart';
import 'package:saas_stock/core/widgets/responsive_helper.dart';
import 'package:saas_stock/features/suppliers/data/models/supplier_model.dart';
import 'suppliers_table_header.dart';
import 'suppliers_table_row.dart';
import 'suppliers_card.dart';

class SuppliersTable extends StatelessWidget {
  final List<SupplierModel> suppliers;

  const SuppliersTable({super.key, required this.suppliers});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    if (isMobile) {
      if (suppliers.isEmpty) {
        return const Center(child: Text("لا يوجد موردين بعد"));
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: suppliers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return SuppliersCard(supplier: suppliers[index]);
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            const SuppliersTableHeader(),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: suppliers.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return SuppliersTableRow(supplier: suppliers[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
