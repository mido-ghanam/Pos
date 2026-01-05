import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:saas_stock/features/customers/data/models/customer_model.dart';
import 'package:saas_stock/features/customers/logic/cubit.dart';
import 'package:saas_stock/features/customers/ui/screens/add_edit_customer_screen.dart';
import 'package:saas_stock/features/sales/logic/cubit.dart';
import 'package:saas_stock/features/sales/ui/screens/customer_sales_invoices_screen.dart';

class CustomersTableRow extends StatelessWidget {
  final CustomerModel customer;

  const CustomersTableRow({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    final isBlocked = customer.blocked == true;
    final isVip = customer.vip == true;
    final isVerified = customer.isVerified == true;

    // ✅ تحويل createdAt من String إلى DateTime (لو موجودة)
    String createdAtFormatted = "-";
    try {
      if (customer.createdAt != null && customer.createdAt!.isNotEmpty) {
        final dt = DateTime.parse(customer.createdAt!).toLocal();
        createdAtFormatted = DateFormat('dd/MM/yyyy').format(dt);
      }
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // ================== العميل ==================
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF7C3AED).withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    color: isBlocked ? Colors.red : const Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    customer.name ?? "-",
                    style: textStyle?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isBlocked ? Colors.red[700] : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isVip) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.star, color: Colors.orange, size: 18),
                ],
              ],
            ),
          ),

          // ================== التليفون ==================
          Expanded(
            flex: 2,
            child: Text(customer.phone ?? "-", style: textStyle),
          ),

          // ================== العنوان ==================
          Expanded(
            flex: 3,
            child: Text(
              customer.address ?? "-",
              style: textStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // ================== حالة العميل ==================
          Expanded(
            flex: 2,
            child: _StatusChip(
              label: isBlocked ? "محظور" : "نشط",
              color: isBlocked ? Colors.red : Colors.green,
            ),
          ),

          // ================== التوثيق ==================
          Expanded(
            flex: 2,
            child: _StatusChip(
              label: isVerified ? "موثّق" : "غير موثّق",
              color: isVerified ? Colors.blue : Colors.grey,
            ),
          ),

          // ================== تاريخ الإنشاء ==================
          Expanded(
            flex: 2,
            child: Text(createdAtFormatted, style: textStyle),
          ),

          // ================== إجراءات ==================
          Expanded(
            flex: 2,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  color: Colors.blue,
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<CustomersCubit>(),
                          child: AddEditCustomerScreen(customer: customer),
                        ),
                      ),
                    );

                    if (result == true && context.mounted) {
                      context
                          .read<CustomersCubit>()
                          .fetchCustomers(); // ✅ ده الصح
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.receipt_long, size: 20),
                  color: const Color(0xFF7C3AED),
                  onPressed: () {
                    final customerId = customer.id ?? '';
                    if (customerId.isEmpty) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context
                              .read<SalesCubit>(), // ✅ نفس cubit بتاع المبيعات
                          child: CustomerSalesInvoicesScreen(
                            customerId: customerId,
                            customerName: customer.name ?? 'عميل',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Chip صغيرة للحالات
class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
