import 'package:flutter/material.dart';
import '../../data/models/refund_invoice_model.dart';

class ReturnInvoiceDialog extends StatelessWidget {
  final RefundInvoiceModel invoice;

  const ReturnInvoiceDialog({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("✅ تم إنشاء المرتجع"),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("رقم المرتجع: ${invoice.id}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text("النوع: ${invoice.partnerType == "sale" ? "مبيعات" : "مشتريات"}"),
            const SizedBox(height: 6),
            Text("الطرف: ${invoice.partyName}"),
            const SizedBox(height: 6),
            Text("الإجمالي: ${invoice.total}"),
            const SizedBox(height: 12),
            const Divider(),
            ...invoice.items.map((i) {
              return ListTile(
                dense: true,
                title: Text(i.productName),
                subtitle: Text("x${i.quantity}"),
                trailing: Text(i.subtotal),
              );
            }).toList(),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          child: const Text("تمام"),
        )
      ],
    );
  }
}
