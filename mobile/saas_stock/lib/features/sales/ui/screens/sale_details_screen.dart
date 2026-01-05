import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saas_stock/core/di/dependency_injection.dart';
import 'package:saas_stock/core/services/receipt_print_service.dart';
import 'package:saas_stock/features/sales/data/models/sale_models.dart';
import 'package:saas_stock/features/sales/logic/cubit.dart';
import 'package:saas_stock/features/sales/logic/states.dart';

class SaleDetailsScreen extends StatelessWidget {
  final int invoiceId;

  const SaleDetailsScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // ✅ أهم سطر في الحل: Cubit جديد خاص بالشاشة دي بس
      create: (_) => getIt<SalesCubit>()..loadSaleDetails(invoiceId),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: Text('تفاصيل فاتورة #$invoiceId'),
          backgroundColor: const Color(0xFF7C3AED),
          actions: [
            IconButton(
              tooltip: "تحديث",
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<SalesCubit>().loadSaleDetails(invoiceId);
              },
            ),
          ],
        ),
        body: BlocBuilder<SalesCubit, SalesState>(
          builder: (context, state) {
            if (state is SaleDetailsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
              );
            }

            if (state is SaleDetailsError) {
              return _ErrorView(
                message: state.error,
                onRetry: () => context.read<SalesCubit>().loadSaleDetails(invoiceId),
              );
            }

            if (state is SaleDetailsLoaded) {
              final SaleResponse sale = state.sale;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeaderSummaryCard(sale: sale),
                    const SizedBox(height: 12),
                    _CustomerInfoCard(sale: sale),
                    const SizedBox(height: 12),
                    _ItemsCard(sale: sale),
                    const SizedBox(height: 14),
                    _ActionsBar(sale: sale),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// ====================== UI Components ======================

class _HeaderSummaryCard extends StatelessWidget {
  final SaleResponse sale;

  const _HeaderSummaryCard({required this.sale});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.receipt_long, color: Color(0xFF7C3AED)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "فاتورة رقم #${sale.id}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "التاريخ: ${sale.createdAt.toString().split('.').first}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("الإجمالي", style: TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  "${sale.total} ج.م",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7C3AED),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerInfoCard extends StatelessWidget {
  final SaleResponse sale;

  const _CustomerInfoCard({required this.sale});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "بيانات العميل",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            _InfoRow(icon: Icons.person, label: "الاسم", value: sale.customer.name),
            _InfoRow(icon: Icons.phone, label: "الهاتف", value: sale.customer.phone ?? "-"),
            _InfoRow(icon: Icons.location_on, label: "العنوان", value: sale.customer.address ?? "-"),

            const Divider(height: 22),

            _InfoRow(icon: Icons.payment, label: "طريقة الدفع", value: sale.paymentMethod),
          ],
        ),
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  final SaleResponse sale;

  const _ItemsCard({required this.sale});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "بنود الفاتورة",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            ...sale.items.map((i) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.shopping_bag, color: Color(0xFF7C3AED)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(i.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            "الكمية: ${i.quantity}  •  سعر الوحدة: ${i.unitPrice}",
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      i.subtotal,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const Divider(height: 18),

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
    );
  }
}

class _ActionsBar extends StatelessWidget {
  final SaleResponse sale;

  const _ActionsBar({required this.sale});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              await ReceiptPrintService.printSaleReceipt(sale);
            },
            icon: const Icon(Icons.print),
            label: const Text("طباعة الفاتورة"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text("رجوع"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 46),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text("إعادة المحاولة"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
