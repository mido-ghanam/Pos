import 'package:flutter/material.dart';
import 'package:saas_stock/core/services/receipt_print_service.dart';
import 'package:saas_stock/features/sales/data/models/sale_models.dart';

class SaleInvoiceDialog extends StatelessWidget {
  final SaleResponse sale;

  const SaleInvoiceDialog({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('🧾 الفاتورة'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("فاتورة رقم: #${sale.id}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("العميل: ${sale.customer.name}"),
              Text("طريقة الدفع: ${sale.paymentMethod}"),
              Text("التاريخ: ${sale.createdAt.toString().split('.').first}"),
              const Divider(height: 24),

              ...sale.items.map((i) {
                return ListTile(
                  dense: true,
                  title: Text(i.productName),
                  subtitle: Text("x${i.quantity}"),
                  trailing: Text(i.subtotal),
                );
              }).toList(),

              const Divider(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "الإجمالي: ${sale.total} ج.م",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF7C3AED),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: () async {
            await ReceiptPrintService.printSaleReceipt(sale);
          },
          icon: const Icon(Icons.print),
          label: const Text("طباعة"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED),
            foregroundColor: Colors.white,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("إغلاق"),
        ),
      ],
    );
  }
}
