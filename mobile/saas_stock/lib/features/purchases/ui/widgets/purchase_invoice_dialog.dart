import 'package:flutter/material.dart';
import 'package:saas_stock/core/services/purchase_receipt_print_service.dart';
import 'package:saas_stock/features/purchases/data/models/purchase_invoice_model.dart';

class PurchaseInvoiceDialog extends StatelessWidget {
  final PurchaseInvoiceModel invoice;

  const PurchaseInvoiceDialog({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('🧾 فاتورة الشراء'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("فاتورة رقم: #${invoice.id}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              Text("المورد: ${invoice.supplier.displayName}"),
              Text("طريقة الدفع: ${invoice.paymentMethod}"),
              Text("التاريخ: ${invoice.createdAt.toString().split('.').first}"),

              const Divider(height: 24),

              ...invoice.items.map((i) {
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
                  "الإجمالي: ${invoice.total} ج.م",
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
            await PurchaseReceiptPrintService.printPurchaseReceipt(invoice);
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
