import 'package:flutter/material.dart';
import 'package:saas_stock/core/widgets/responsive_helper.dart';
import 'package:saas_stock/features/customers/data/models/customer_model.dart';
import 'package:saas_stock/features/customers/ui/widgets/customers_table_header.dart';
import 'package:saas_stock/features/customers/ui/widgets/customers_table_row.dart';
import 'package:saas_stock/features/customers/ui/widgets/customers_card.dart';

class CustomersTable extends StatelessWidget {
final List<CustomerModel> customers;

  const CustomersTable({super.key, required this.customers});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    if (isMobile) {
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: customers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return CustomersCard(customer: customers[index]);
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
            const CustomersTableHeader(),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: customers.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return CustomersTableRow(customer: customers[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
